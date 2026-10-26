// OpenCode Live Quota Monitor Widget
// Real-time visual indicator for Google Antigravity & AI models

(function () {
  if (window.__OPENCODE_QUOTA_WIDGET_LOADED__) return;
  window.__OPENCODE_QUOTA_WIDGET_LOADED__ = true;

  const style = document.createElement("style");
  style.textContent = `
    .oc-quota-container {
      position: fixed;
      bottom: 12px;
      right: 16px;
      z-index: 99999;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
      font-size: 11px;
      user-select: none;
    }
    .oc-quota-pill {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 5px 10px;
      background: var(--v2-background-bg-elevated, rgba(20, 20, 22, 0.85));
      backdrop-filter: blur(12px);
      border: 1px solid var(--v2-border-subtle, rgba(255, 255, 255, 0.1));
      border-radius: 9999px;
      color: var(--v2-text-base, #e4e4e7);
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.35);
      cursor: pointer;
      transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .oc-quota-pill:hover {
      border-color: var(--v2-border-strong, rgba(255, 255, 255, 0.25));
      transform: translateY(-1px);
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.45);
    }
    .oc-quota-chip {
      display: flex;
      align-items: center;
      gap: 5px;
    }
    .oc-quota-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: #10b981;
    }
    .oc-quota-dot.green { background: #10b981; box-shadow: 0 0 6px rgba(16, 185, 129, 0.6); }
    .oc-quota-dot.yellow { background: #f59e0b; box-shadow: 0 0 6px rgba(245, 158, 11, 0.6); }
    .oc-quota-dot.red { background: #ef4444; box-shadow: 0 0 6px rgba(239, 68, 68, 0.6); }
    .oc-quota-divider {
      width: 1px;
      height: 12px;
      background: rgba(255, 255, 255, 0.15);
    }
    .oc-quota-modal {
      display: none;
      position: absolute;
      bottom: calc(100% + 8px);
      right: 0;
      width: 320px;
      background: var(--v2-background-bg-elevated, #18181b);
      border: 1px solid var(--v2-border-strong, rgba(255, 255, 255, 0.15));
      border-radius: 12px;
      padding: 14px;
      color: #fafafa;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.6);
      backdrop-filter: blur(16px);
      flex-direction: column;
      gap: 12px;
      animation: ocFadeIn 0.15s ease-out;
    }
    .oc-quota-modal.open {
      display: flex;
    }
    @keyframes ocFadeIn {
      from { opacity: 0; transform: translateY(4px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .oc-quota-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      padding-bottom: 8px;
      font-weight: 600;
      font-size: 11px;
      color: #a1a1aa;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    .oc-quota-group {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .oc-quota-group-title {
      font-weight: 600;
      color: #38bdf8;
      display: flex;
      justify-content: space-between;
    }
    .oc-quota-bar-bg {
      width: 100%;
      height: 6px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 3px;
      overflow: hidden;
    }
    .oc-quota-bar-fill {
      height: 100%;
      border-radius: 3px;
      transition: width 0.3s ease;
    }
    .oc-quota-bar-fill.green { background: #10b981; }
    .oc-quota-bar-fill.yellow { background: #f59e0b; }
    .oc-quota-bar-fill.red { background: #ef4444; }
    .oc-quota-meta {
      display: flex;
      justify-content: space-between;
      font-size: 10px;
      color: #71717a;
    }
  `;
  document.head.appendChild(style);

  const container = document.createElement("div");
  container.className = "oc-quota-container";

  container.innerHTML = `
    <div class="oc-quota-modal" id="ocQuotaModal">
      <div class="oc-quota-header">
        <span>⚡ Antigravity Quota Status</span>
        <span id="ocQuotaLastUpdate" style="font-weight:normal; font-size:10px;">live</span>
      </div>
      <div id="ocQuotaList" style="display:flex; flex-direction:column; gap:10px;">
        <div style="color:#71717a;">Cargando cuota...</div>
      </div>
    </div>
    <div class="oc-quota-pill" id="ocQuotaPill" title="Click para ver detalle de cuota">
      <div class="oc-quota-chip">
        <span class="oc-quota-dot green" id="ocDotArgon"></span>
        <span id="ocTextArgon">Argon: --%</span>
      </div>
      <div class="oc-quota-divider"></div>
      <div class="oc-quota-chip">
        <span class="oc-quota-dot green" id="ocDotFlash"></span>
        <span id="ocTextFlash">Flash(5h): --%</span>
      </div>
      <div class="oc-quota-divider"></div>
      <div class="oc-quota-chip">
        <span class="oc-quota-dot green" id="ocDotClaude"></span>
        <span id="ocTextClaude">Claude(5h): --%</span>
      </div>
    </div>
  `;
  document.body.appendChild(container);

  const pill = document.getElementById("ocQuotaPill");
  const modal = document.getElementById("ocQuotaModal");

  pill.addEventListener("click", (e) => {
    e.stopPropagation();
    modal.classList.toggle("open");
  });

  document.addEventListener("click", (e) => {
    if (!container.contains(e.target)) {
      modal.classList.remove("open");
    }
  });

  function getStatusColor(pct) {
    if (pct >= 60) return "green";
    if (pct >= 25) return "yellow";
    return "red";
  }

  function formatTimeRemaining(isoDate) {
    if (!isoDate) return "";
    try {
      const target = new Date(isoDate).getTime();
      const diff = Math.max(0, target - Date.now());
      const hrs = Math.floor(diff / 3600000);
      const mins = Math.floor((diff % 3600000) / 60000);
      if (hrs > 24) {
        return Math.floor(hrs / 24) + "d restantes";
      }
      return `${hrs}h ${mins}m para reset`;
    } catch {
      return "";
    }
  }

  async function updateQuota() {
    try {
      const res = await fetch("/api/live-quota");
      if (!res.ok) return;
      const data = await res.json();
      if (!data || !data.groups) return;

      let modalHtml = "";

      for (const g of data.groups) {
        const name = g.displayName || "Modelo";
        let bucketHtml = "";

        for (const b of g.buckets) {
          const frac = b.remainingFraction ?? 1.0;
          const pct = (frac * 100).toFixed(1);
          const color = getStatusColor(pct);
          const timer = formatTimeRemaining(b.resetTime);

          if (name.includes("Argon")) {
            document.getElementById("ocTextArgon").textContent = `Argon: ${Math.round(pct)}%`;
            document.getElementById("ocDotArgon").className = `oc-quota-dot ${color}`;
          } else if (name.includes("Gemini") && b.window === "5h") {
            document.getElementById("ocTextFlash").textContent = `Flash(5h): ${Math.round(pct)}%`;
            document.getElementById("ocDotFlash").className = `oc-quota-dot ${color}`;
          } else if (name.includes("Claude") && b.window === "5h") {
            document.getElementById("ocTextClaude").textContent = `Claude(5h): ${Math.round(pct)}%`;
            document.getElementById("ocDotClaude").className = `oc-quota-dot ${color}`;
          }

          bucketHtml += `
            <div style="display:flex; flex-direction:column; gap:2px; margin-top:4px;">
              <div style="display:flex; justify-content:space-between; font-size:10px;">
                <span style="color:#d4d4d8;">${b.displayName || b.bucketId} (${b.window})</span>
                <span style="font-weight:600; color:#fafafa;">${pct}%</span>
              </div>
              <div class="oc-quota-bar-bg">
                <div class="oc-quota-bar-fill ${color}" style="width: ${pct}%"></div>
              </div>
              <div class="oc-quota-meta">
                <span>${timer}</span>
              </div>
            </div>
          `;
        }

        modalHtml += `
          <div class="oc-quota-group">
            <div class="oc-quota-group-title">
              <span>${name}</span>
            </div>
            ${bucketHtml}
          </div>
        `;
      }

      document.getElementById("ocQuotaList").innerHTML = modalHtml;
      document.getElementById("ocQuotaLastUpdate").textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    } catch (e) {
      console.warn("[QuotaWidget] Fetch error:", e);
    }
  }

  updateQuota();
  setInterval(updateQuota, 30000);
})();
