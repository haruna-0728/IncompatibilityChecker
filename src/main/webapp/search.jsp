<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="checker.bean.Drug" %>
<%@ page import="checker.bean.Incompatibility" %>
<% request.setAttribute("activeTab", "search"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>配合禁忌チェック</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .drug-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 16px;
        }
        .drug-chip {
            padding: 8px 14px;
            border-radius: 20px;
            border: 1px solid var(--b2);
            background: var(--s2);
            color: var(--t2);
            font-size: 14px;
            cursor: pointer;
            user-select: none;
            transition: background 0.15s, border-color 0.15s, color 0.15s;
        }
        .drug-chip.selected {
            background: var(--blue);
            border-color: var(--blue);
            color: #fff;
        }
        .selected-pills {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            min-height: 20px;
            margin-bottom: 16px;
        }
        .pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 20px;
            background: var(--blue);
            color: #fff;
            font-size: 13px;
        }
        .pill-remove {
            cursor: pointer;
            font-weight: bold;
        }
        #checkBtn {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 10px;
            background: var(--blue);
            color: #fff;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }
        #checkBtn:disabled {
            background: var(--s2);
            color: var(--t3);
            cursor: not-allowed;
        }
        .result-summary {
            margin-top: 20px;
            padding: 14px 16px;
            border-radius: 10px;
            font-weight: bold;
        }
        .result-summary.danger {
            background: rgba(220, 53, 69, 0.15);
            border: 1px solid var(--red);
            color: var(--red);
        }
        .result-summary.safe {
            background: rgba(40, 167, 69, 0.15);
            border: 1px solid var(--green);
            color: var(--green);
        }
        .result-summary .label {
            font-size: 12px;
            font-weight: normal;
            color: var(--t3);
            display: block;
            margin-bottom: 4px;
        }
        .pair-card {
            margin-top: 12px;
            padding: 14px 16px;
            border-radius: 10px;
            background: var(--s2);
            border-left: 4px solid var(--red);
        }
        .pair-card.medium {
            border-left-color: var(--amber);
        }
        .pair-card .pair-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: bold;
            color: var(--t1);
            margin-bottom: 6px;
        }
        .severity-tag {
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 10px;
            background: var(--red);
            color: #fff;
        }
        .severity-tag.medium {
            background: var(--amber);
        }
        .pair-reason {
            color: var(--t2);
            font-size: 14px;
            margin-bottom: 8px;
        }
        .source-tag {
            display: inline-block;
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 10px;
            background: var(--s1);
            color: var(--t3);
            border: 1px solid var(--b2);
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="page-wrapper">
        <h1>配合禁忌チェック</h1>

        <c:if test="${not empty errorMessage}">
            <p class="error-message">${errorMessage}</p>
        </c:if>

        <div class="card">
            <label>薬剤を選択(複数可):</label>

            <div class="drug-grid" id="drugGrid">
                <c:forEach var="drug" items="${drugList}">
                    <div class="drug-chip"
                         data-id="${drug.drugId}"
                         data-name="${drug.drugName}"
                         onclick="toggleDrug(this)">
                        ${drug.drugName}
                    </div>
                </c:forEach>
            </div>

            <div class="selected-pills" id="selectedPills"></div>

            <button id="checkBtn" disabled onclick="checkPairs()">配合禁忌をチェック</button>
        </div>

        <div id="resultArea"></div>

        <p class="disclaimer">
            ⚠ 本アプリは代表的な薬剤・配合禁忌情報を収録した簡易版です。
            実際の臨床判断には必ず添付文書・薬剤師への確認を行ってください。
        </p>
    </div>

    <jsp:include page="tab-nav.jsp" />

    <script>
    // --- サーバーから薬剤・配合禁忌データを埋め込み ---
    const incompatibilityList = [
        <c:forEach var="inc" items="${incompatibilityList}" varStatus="status">
        {
            drugIdA: ${inc.drugIdA},
            drugIdB: ${inc.drugIdB},
            severity: "${inc.severity}",
            reason: "${inc.reason}",
            source: "${inc.source}"
        }${!status.last ? ',' : ''}
        </c:forEach>
    ];

    // --- 選択状態の管理 ---
    let selectedDrugs = []; // { id, name }

    function toggleDrug(el) {
        const id = parseInt(el.dataset.id);
        const name = el.dataset.name;
        const idx = selectedDrugs.findIndex(d => d.id === id);

        if (idx === -1) {
            selectedDrugs.push({ id, name });
            el.classList.add('selected');
        } else {
            selectedDrugs.splice(idx, 1);
            el.classList.remove('selected');
        }
        renderPills();
        updateButton();
        document.getElementById('resultArea').innerHTML = '';
    }

    function removeDrug(id) {
        selectedDrugs = selectedDrugs.filter(d => d.id !== id);
        const chip = document.querySelector('.drug-chip[data-id="' + id + '"]');
        if (chip) chip.classList.remove('selected');
        renderPills();
        updateButton();
        document.getElementById('resultArea').innerHTML = '';
    }

    function renderPills() {
        const container = document.getElementById('selectedPills');
        container.innerHTML = selectedDrugs.map(d =>
            '<span class="pill">' + d.name +
            ' <span class="pill-remove" onclick="removeDrug(' + d.id + ')">×</span></span>'
        ).join('');
    }

    function updateButton() {
        document.getElementById('checkBtn').disabled = selectedDrugs.length < 2;
    }

    // --- 判定処理 ---
    function checkPairs() {
        const pairResults = [];

        for (let i = 0; i < selectedDrugs.length; i++) {
            for (let j = i + 1; j < selectedDrugs.length; j++) {
                const a = selectedDrugs[i];
                const b = selectedDrugs[j];
                const match = incompatibilityList.find(inc =>
                    (inc.drugIdA === a.id && inc.drugIdB === b.id) ||
                    (inc.drugIdA === b.id && inc.drugIdB === a.id)
                );
                pairResults.push({
                    nameA: a.name,
                    nameB: b.name,
                    match: match || null
                });
            }
        }

        renderResults(pairResults);
    }

    function renderResults(pairResults) {
        const dangerousList = pairResults.filter(p => p.match !== null);
        const resultArea = document.getElementById('resultArea');

        let html = '';

        if (dangerousList.length > 0) {
            html += '<div class="result-summary danger">' +
                '<span class="label">選択' + selectedDrugs.length + '剤中</span>' +
                '⛔ ' + dangerousList.length + '件の配合禁忌を検出' +
                '</div>';
        } else {
            html += '<div class="result-summary safe">' +
                '<span class="label">選択' + selectedDrugs.length + '剤中</span>' +
                '✓ 配合禁忌は検出されませんでした' +
                '</div>';
        }

        dangerousList.forEach(p => {
            const isHigh = p.match.severity === '配合不可';
            const cardClass = isHigh ? '' : 'medium';
            const tagClass = isHigh ? '' : 'medium';

            html += '<div class="pair-card ' + cardClass + '">' +
                '<div class="pair-title">⛔ ' + p.nameA + ' + ' + p.nameB +
                ' <span class="severity-tag ' + tagClass + '">' + p.match.severity + '</span>' +
                '</div>' +
                '<div class="pair-reason">' + p.match.reason + '</div>' +
                '<span class="source-tag">' + (p.match.source || '内蔵データ') + '</span>' +
                '</div>';
        });

        resultArea.innerHTML = html;
    }
    </script>
</body>
</html>