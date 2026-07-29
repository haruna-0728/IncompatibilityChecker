<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<% request.setAttribute("activeTab", "drip"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>点滴滴下計算</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="page-wrapper">
        <h1>点滴滴下計算</h1>

        <div class="mode-nav" id="mode-nav">
            <button class="mode-link active" data-mode="normal">一般輸液</button>
            <button class="mode-link" data-mode="transfusion">輸血</button>
            <button class="mode-link" data-mode="narcotic">麻薬</button>
            <button class="mode-link" data-mode="heparin">ヘパリン</button>
            <button class="mode-link" data-mode="kalium">カリウム</button>
            <button class="mode-link" data-mode="pressor">昇圧剤</button>
            <button class="mode-link" data-mode="tpn">TPN</button>
            <button class="mode-link" data-mode="other">その他</button>
        </div>

        <div id="category-alert"></div>

        <div class="card">
            <!-- 輸血モード専用フィールド -->
            <div id="fields-transfusion" style="display:none;">
                <div class="form-group">
                    <label for="totalVolume">輸血量(mL):</label>
                    <input type="number" step="any" id="totalVolume" oninput="calcDrip()">
                </div>
                <p class="disclaimer" style="margin-top:16px;">
                    ※成人・輸血セット(15滴/mL)を想定。日本赤十字社の基準に基づき、
                    開始10~15分は1mL/分、その後は5mL/分として計算します。
                </p>
            </div>

            <!-- 通常モード共通フィールド -->
            <div id="fields-normal">
                <div class="form-group">
                    <label for="volume">輸液量(mL):</label>
                    <input type="number" step="any" id="volume" oninput="calcDrip()">
                </div>
                <div class="form-group">
                    <label for="minutes">投与時間(分):</label>
                    <input type="number" step="any" id="minutes" oninput="calcDrip()">
                </div>
                <div class="form-group">
                    <label for="setFactor">点滴セット:</label>
                    <select id="setFactor" onchange="calcDrip()">
                        <option value="20">一般成人用(20滴/mL)</option>
                        <option value="60">小児・微量用(60滴/mL)</option>
                    </select>
                </div>
                <div class="form-group" id="kalium-field" style="display:none;">
                    <label for="kaliumDose">カリウム投与量(mEq、輸液バッグ全体、任意):</label>
                    <input type="number" step="any" id="kaliumDose" oninput="calcDrip()" placeholder="例: 20(KCL 20mEqを希釈した場合)">
                </div>
            </div>
        </div>

        <div id="result-area"></div>

        <p class="disclaimer">
            ⚠ 本計算結果は参考値です。実際の投与にあたっては、必ず医師の指示・添付文書・院内プロトコルを確認してください。
        </p>
    </div>

    <jsp:include page="tab-nav.jsp" />

    <script>
    let currentMode = "normal";
    const KALIUM_MAX = 20.0;

    const CATEGORY_ALERTS = {
        kalium: '<div class="alert-e">⛔ 原液の静脈内直接投与は絶対禁止(心停止リスク)</div><div class="alert-w">⚠ 最大濃度40mEq/L・最大速度20mEq/時間を厳守</div>',
        narcotic: '<div class="alert-w">⚠ 麻薬は施錠管理・使用量記録(帳簿)が必要です</div>',
        tpn: '<div class="alert-w">⚠ 専用ラインを使用。他剤との混注は原則禁止</div>',
        pressor: '<div class="alert-w">⚠ ライン抜去・閉塞・急速投与に注意</div>'
    };

    document.querySelectorAll('#mode-nav .mode-link').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('#mode-nav .mode-link').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentMode = btn.dataset.mode;
            switchFields();
            calcDrip();
        });
    });

    function switchFields() {
        document.getElementById('fields-transfusion').style.display = (currentMode === 'transfusion') ? 'block' : 'none';
        document.getElementById('fields-normal').style.display = (currentMode === 'transfusion') ? 'none' : 'block';
        document.getElementById('kalium-field').style.display = (currentMode === 'kalium') ? 'block' : 'none';
        document.getElementById('category-alert').innerHTML = CATEGORY_ALERTS[currentMode] || '';
    }

    function round1(v) { return Math.round(v * 10) / 10; }

    function calcEndTime(minutes) {
        const now = new Date();
        const end = new Date(now.getTime() + minutes * 60000);
        const hh = String(end.getHours()).padStart(2, '0');
        const mm = String(end.getMinutes()).padStart(2, '0');
        return hh + ':' + mm;
    }

    function calcDrip() {
        const resultArea = document.getElementById('result-area');

        if (currentMode === 'transfusion') {
            const totalVolume = parseFloat(document.getElementById('totalVolume').value);
            if (!totalVolume || totalVolume <= 0) { resultArea.innerHTML = ''; return; }

            const startMinutes = 15.0;
            const startVolume = 1.0 * startMinutes;
            let totalMinutes;
            if (totalVolume <= startVolume) {
                totalMinutes = totalVolume / 1.0;
            } else {
                totalMinutes = startMinutes + (totalVolume - startVolume) / 5.0;
            }

            resultArea.innerHTML = `
                <div class="result-safe">
                    <div class="result-label">点滴速度</div>
                    <div class="result-value">75.0<span class="result-unit">滴/分</span></div>
                    <div class="result-sub">維持速度(開始10~15分は 15.0 滴/分)</div>
                    <div class="result-grid">
                        <div class="result-cell"><div class="result-cell-label">開始時</div><div class="result-cell-value">15.0 滴/分</div></div>
                        <div class="result-cell"><div class="result-cell-label">終了予定時刻</div><div class="result-cell-value">${calcEndTime(totalMinutes)}</div></div>
                    </div>
                    <div class="alert-w">
                        <span>⚠</span>
                        <div>
                            <strong>副作用の観察が必要です</strong>
                            観察タイミング:輸血開始前・開始後5分・開始後15分・輸血終了後
                            <ul>
                                <li>発熱・悪寒、顔面紅潮</li>
                                <li>蕁麻疹・掻痒感などのアレルギー症状</li>
                                <li>呼吸困難、血圧低下・頻脈</li>
                                <li>腰背部痛・胸痛・気分不快</li>
                            </ul>
                            異常があれば直ちに輸血を中断し、医師へ報告してください。
                        </div>
                    </div>
                </div>`;
            return;
        }

        const volume = parseFloat(document.getElementById('volume').value);
        const minutes = parseFloat(document.getElementById('minutes').value);
        const setFactor = parseFloat(document.getElementById('setFactor').value);

        if (!volume || !minutes || volume <= 0 || minutes <= 0) { resultArea.innerHTML = ''; return; }

        const dripRate = round1(volume / minutes * setFactor);
        const mlPerHour = round1(volume / minutes * 60);
        const endTime = calcEndTime(minutes);

        let kaliumHtml = '';
        let cardClass = 'result-safe';

        if (currentMode === 'kalium') {
            const kaliumDose = parseFloat(document.getElementById('kaliumDose').value);
            if (kaliumDose && kaliumDose > 0) {
                const meqPerHour = round1(kaliumDose / minutes * 60);
                const exceeded = meqPerHour > KALIUM_MAX;
                cardClass = exceeded ? 'result-danger' : 'result-safe';
                kaliumHtml = exceeded
                    ? `<div class="alert-e">⛔ 投与速度 ${meqPerHour} mEq/時 は上限(20mEq/時)を超えています。速度を見直してください。</div>`
                    : `<div class="result-sub">投与速度:${meqPerHour} mEq/時(上限20mEq/時以内)</div>`;
            }
        }

        resultArea.innerHTML = `
            <div class="${cardClass}">
                <div class="result-label">点滴速度</div>
                <div class="result-value">${dripRate}<span class="result-unit">滴/分</span></div>
                <div class="result-grid">
                    <div class="result-cell"><div class="result-cell-label">終了予定時刻</div><div class="result-cell-value">${endTime}</div></div>
                    <div class="result-cell"><div class="result-cell-label">mL/時間</div><div class="result-cell-value">${mlPerHour}</div></div>
                </div>
                ${kaliumHtml}
            </div>`;
    }

    switchFields();
    </script>
</body>
</html>