import http from "node:http";
import net from "node:net";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const WIDGET_JS_PATH = path.join(__dirname, "_quota_widget.js");

const TARGET_PORT = 4096;
const TARGET_HOST = "127.0.0.1";
const LISTEN_PORT = 4095;
const LISTEN_HOST = "127.0.0.1";
const QUOTA_API_URL = "http://127.0.0.1:8877/v1/quota";

const server = http.createServer((req, res) => {
  // 1. Ruta directa para servir el script del widget
  if (req.url === "/_quota_widget.js") {
    fs.readFile(WIDGET_JS_PATH, (err, data) => {
      if (err) {
        res.writeHead(500, { "Content-Type": "text/plain" });
        return res.end("Error loading widget script");
      }
      res.writeHead(200, {
        "Content-Type": "application/javascript; charset=utf-8",
        "Cache-Control": "no-cache",
      });
      res.end(data);
    });
    return;
  }

  // 2. Ruta para obtener la cuota en vivo (consulta el proxy :8877)
  if (req.url === "/api/live-quota") {
    http.get(QUOTA_API_URL, (apiRes) => {
      res.writeHead(apiRes.statusCode || 200, {
        "Content-Type": "application/json; charset=utf-8",
        "Cache-Control": "no-cache",
        "Access-Control-Allow-Origin": "*",
      });
      apiRes.pipe(res);
    }).on("error", (err) => {
      res.writeHead(502, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: err.message }));
    });
    return;
  }

  // 3. Proxy transparente hacia Op3nCode (:4096)
  const options = {
    hostname: TARGET_HOST,
    port: TARGET_PORT,
    path: req.url,
    method: req.method,
    headers: { ...req.headers, host: `localhost:${TARGET_PORT}` },
  };

  const isHtmlRequest =
    req.method === "GET" &&
    (req.url === "/" || req.url?.startsWith("/?") || req.headers.accept?.includes("text/html"));

  if (isHtmlRequest) {
    delete options.headers["accept-encoding"];
  }

  const proxyReq = http.request(options, (proxyRes) => {
    const contentType = proxyRes.headers["content-type"] || "";
    const isHtmlResponse = contentType.includes("text/html");

    if (isHtmlResponse) {
      const chunks = [];
      proxyRes.on("data", (chunk) => chunks.push(chunk));
      proxyRes.on("end", () => {
        let body = Buffer.concat(chunks).toString("utf-8");
        const scriptTag = '<script src="/_quota_widget.js" defer></script>';
        if (body.includes("</body>")) {
          body = body.replace("</body>", `${scriptTag}\n</body>`);
        } else if (body.includes("</html>")) {
          body = body.replace("</html>", `${scriptTag}\n</html>`);
        } else {
          body += scriptTag;
        }

        const newHeaders = { ...proxyRes.headers };
        delete newHeaders["content-length"];
        delete newHeaders["content-encoding"];
        newHeaders["content-length"] = Buffer.byteLength(body);

        res.writeHead(proxyRes.statusCode || 200, newHeaders);
        res.end(body);
      });
    } else {
      res.writeHead(proxyRes.statusCode || 200, proxyRes.headers);
      proxyRes.pipe(res);
    }
  });

  proxyReq.on("error", (err) => {
    res.writeHead(502, { "Content-Type": "text/plain" });
    res.end("OpenCode Backend Offline: " + err.message);
  });

  req.pipe(proxyReq);
});

// Soporte completo de WebSockets
server.on("upgrade", (req, socket, head) => {
  const proxySocket = net.connect(TARGET_PORT, TARGET_HOST, () => {
    proxySocket.write(
      `${req.method} ${req.url} HTTP/${req.httpVersion}\r\n` +
        Object.entries(req.headers)
          .map(([k, v]) => `${k}: ${v}`)
          .join("\r\n") +
        "\r\n\r\n"
    );
    if (head && head.length > 0) proxySocket.write(head);
    socket.pipe(proxySocket).pipe(socket);
  });

  proxySocket.on("error", () => socket.destroy());
  socket.on("error", () => proxySocket.destroy());
});

server.listen(LISTEN_PORT, LISTEN_HOST, () => {
  console.log(`[OpenCode Injector] Listening on http://${LISTEN_HOST}:${LISTEN_PORT} -> :${TARGET_PORT}`);
});
