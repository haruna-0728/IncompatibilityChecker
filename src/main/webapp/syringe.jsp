<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<% request.setAttribute("activeTab", "syringe"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>シリンジポンプ計算</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="page-wrapper">
        <h1>シリンジポンプ計算</h1>

        <div class="mode-nav" id="cat-nav">
            <button class="mode-link active" data-cat="pressor">昇圧剤</button>
            <button class="mode-link" data-cat="narcotic">麻薬</button>
            <button class="mode-link" data-cat="heparin">ヘパリン</button>
            <button class="mode-link" data-cat="kalium">カリウム</button>
            <button class="mode-link" data-cat="other">その他</button>
        </div>

        <div id="category-alert">
            <div class="alert-w">⚠ 麻薬・ヘパリン・カリウムは二重確認を実施してください。</div>
        </div>

        <div class="card">
            <div class="form-group">
                <label for="drugName">薬剤名:</label>
                <select id="drugName" onchange="updateAdvisory()"></select>
            </div>
            <div class="form-group">
                <label>標準濃度・規格(参考):</label>
                <div id="advisory" style="font-size:13px; color:var(--t2); background:var(--s2); border:1px solid var(--b2); border-radius:var(--r); padding:10px 13px;">
                    薬剤を選択してください
                </div>
            </div>

            <div class="form-group">
                <label for="drugAmount">薬剤量(mg/単位/mEqなど):</label>
                <input type="number" step="any" id="drugAmount" oninput="calcSyringe()" placeholder="例: 200">
            </div>
            <div class="form-group">
                <label for="totalVolume">希釈後総量(mL):</label>
                <input type="number" step="any" id="totalVolume" oninput="calcSyringe()" placeholder="例: 50">
            </div>
            <div class="form-group">
                <label for="weight">体重(kg、γ計算時のみ必須):</label>
                <input type="number" step="any" id="weight" oninput="calcSyringe()" placeholder="任意">
            </div>
            <div class="form-group">
                <label for="speedMethod">速度の指定方法:</label>
                <select id="speedMethod" onchange="onMethodChange()">
                    <option value="mlPerHour">mL/時間</option>
                    <option value="gammaPerMin">μg/kg/分(γ)</option>
                    <option value="gammaPerHour">μg/kg/時間</option>
                    <option value="unitPerHour">単位(mEq)/時</option>
                </select>
            </div>
            <div class="form-group">
                <label id="speedLabel" for="speedValue">投与速度(mL/時):</label>
                <input type="number" step="any" id="speedValue" oninput="calcSyringe()" placeholder="例: 3">
            </div>
        </div>

        <div id="result-area"></div>

        <p class="disclaimer">
            ⚠ 濃度は施設・指示によって異なります。必ず実際に準備した薬剤量・総液量を確認のうえ入力してください。
            本計算結果は参考値であり、実際の投与にあたっては医師の指示・添付文書・院内プロトコルを確認してください。
        </p>
    </div>

    <jsp:include page="tab-nav.jsp" />

    <script>
    const DRUGS = {
        pressor: ["ドパミン", "ノルアドレナリン", "ドブタミン", "アドレナリン"],
        narcotic: ["モルヒネ", "フェンタニル", "ミダゾラム", "オキシコドン"],
        heparin: ["ヘパリンナトリウム"],
        kalium: ["塩化カリウム"],
        other: ["その他薬剤"]
    };

    const ADVISORY = {
        "ノルアドレナリン": "一般的な使用範囲の目安:0.05~0.3γ(施設プロトコルに従ってください)",
        "ドブタミン": "一般的な使用範囲の目安:1~20γ(施設プロトコルに従ってください)"
    };

    const SPEED_LABELS = {
        mlPerHour: "投与速度(mL/時):",
        gammaPerMin: "指示量(μg/kg/分):",
        gammaPerHour: "指示量(μg/kg/時間):",
        unitPerHour: "指示量(単位 または mEq/時):"
    };

    let currentCat = "pressor";

    document.querySelectorAll('#cat-nav .mode-link').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('#cat-nav .mode-link').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentCat = btn.dataset.cat;
            populateDrugs();
            calcSyringe();
        });
    });

    function populateDrugs() {
        const sel = document.getElementById('drugName');
        sel.innerHTML = '<option value="">選択してください</option>';
        DRUGS[currentCat].forEach(name => {
            const opt = document.createElement('option');
            opt.value = name;
            opt.textContent = name;
            sel.appendChild(opt);
        });
        updateAdvisory();
    }

    function updateAdvisory() {
        const drug = document.getElementById('drugName').value;
        const box = document.getElementById('advisory');
        box.textContent = ADVISORY[drug] || "施設の標準希釈方法・添付文書を確認してください(自動入力なし)";
    }

    function onMethodChange() {
        const method = document.getElementById('speedMethod').value;
        document.getElementById('speedLabel').textContent = SPEED_LABELS[method];
        calcSyringe();
    }

    function round2(v) { return Math.round(v * 100) / 100; }

    function calcSyringe() {
        const resultArea = document.getElementById('result-area');
        const drugAmount = parseFloat(document.getElementById('drugAmount').value);
        const totalVolume = parseFloat(document.getElementById('totalVolume').value);
        const weight = parseFloat(document.getElementById('weight').value);
        const method = document.getElementById('speedMethod').value;
        const speedValue = parseFloat(document.getElementById('speedValue').value);

        if (!drugAmount || !totalVolume || drugAmount <= 0 || totalVolume <= 0 || !speedValue || speedValue <= 0) {
            resultArea.innerHTML = '';
            return;
        }

        const concentration = drugAmount / totalVolume; // 単位/mL (mg/mL, 単位/mL, mEq/mLなど)
        let mlPerHour;
        let needsWeight = (method === 'gammaPerMin' || method === 'gammaPerHour');

        if (needsWeight && (!weight || weight <= 0)) {
            resultArea.innerHTML = '<p class="error-message">この指定方法には体重の入力が必要です。</p>';
            return;
        }

        if (method === 'mlPerHour') {
            mlPerHour = speedValue;
        } else if (method === 'gammaPerMin') {
            mlPerHour = weight * speedValue * 0.06 / concentration;
        } else if (method === 'gammaPerHour') {
            mlPerHour = weight * speedValue / 1000 / concentration;
        } else if (method === 'unitPerHour') {
            mlPerHour = speedValue / concentration;
        }

        mlPerHour = round2(mlPerHour);

        let gammaInfo = '';
        if (method !== 'gammaPerMin' && weight > 0) {
            const gammaPerMin = round2(mlPerHour * concentration / 0.06 / weight);
            gammaInfo = `<div class="result-sub">参考:約 ${gammaPerMin} γ(μg/kg/分)に相当</div>`;
        }

        resultArea.innerHTML = `
            <div class="result-safe">
                <div class="result-label">シリンジポンプ設定速度</div>
                <div class="result-value">${mlPerHour}<span class="result-unit">mL/時</span></div>
                ${gammaInfo}
            </div>`;
    }

    populateDrugs();
    </script>
</body>
</html>