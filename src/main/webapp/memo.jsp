<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% request.setAttribute("activeTab", "memo"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>確認メモ</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .drug-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 12px;
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
        }
        .drug-chip.selected {
            background: var(--blue);
            border-color: var(--blue);
            color: #fff;
        }
        .add-drug-row {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }
        .add-drug-row input[type="text"] {
            flex: 1;
            padding: 10px 12px;
            border-radius: 8px;
            border: 1px solid var(--b2);
            background: var(--s1);
            color: var(--t1);
        }
        .add-drug-row button {
            padding: 10px 16px;
            border-radius: 8px;
            border: none;
            background: var(--s2);
            color: var(--t1);
            cursor: pointer;
        }
        .selected-pills {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            min-height: 20px;
            margin-bottom: 16px;
            color: var(--t3);
            font-size: 13px;
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
        textarea#memoText {
            width: 100%;
            min-height: 80px;
            padding: 10px 12px;
            border-radius: 8px;
            border: 1px solid var(--b2);
            background: var(--s1);
            color: var(--t1);
            resize: vertical;
        }
        select#urgency, input#submitter {
            width: 100%;
            padding: 10px 12px;
            border-radius: 8px;
            border: 1px solid var(--b2);
            background: var(--s1);
            color: var(--t1);
        }
        .form-row-2col {
            display: flex;
            gap: 16px;
            margin-top: 12px;
        }
        .form-row-2col > div {
            flex: 1;
        }
        #saveMemoBtn {
            width: 100%;
            margin-top: 16px;
            padding: 14px;
            border: none;
            border-radius: 10px;
            background: var(--blue);
            color: #fff;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }
        .memo-card {
            margin-top: 12px;
            padding: 14px 16px;
            border-radius: 10px;
            background: var(--s2);
            border-left: 4px solid var(--blue);
        }
        .memo-card.resolved {
            border-left-color: var(--green);
            opacity: 0.6;
        }
        .memo-card.urgency-緊急 {
            border-left-color: var(--red);
        }
        .memo-card.urgency-要確認 {
            border-left-color: var(--amber);
        }
        .memo-drugs {
            font-weight: bold;
            color: var(--t1);
            margin-bottom: 4px;
        }
        .memo-text {
            color: var(--t2);
            font-size: 14px;
            margin-bottom: 8px;
        }
        .memo-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 12px;
            color: var(--t3);
        }
        .memo-tag {
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 10px;
            background: var(--s1);
            border: 1px solid var(--b2);
        }
        .memo-actions form {
            display: inline;
        }
        .memo-actions button {
            margin-left: 8px;
            padding: 4px 10px;
            border-radius: 8px;
            border: 1px solid var(--b2);
            background: var(--s1);
            color: var(--t2);
            font-size: 12px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="page-wrapper">
        <h1>確認メモ</h1>

        <c:if test="${not empty errorMessage}">
            <p class="error-message">${errorMessage}</p>
        </c:if>

        <div class="card">
            <form action="memo" method="post" id="memoForm">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="drugNames" id="drugNamesInput">

                <label>確認したい薬剤:</label>
                <div class="drug-grid" id="drugGrid">
                    <c:forEach var="drug" items="${drugList}">
                        <div class="drug-chip" data-name="${drug.drugName}" onclick="toggleDrug(this)">
                            ${drug.drugName}
                        </div>
                    </c:forEach>
                </div>

                <div class="add-drug-row">
                    <input type="text" id="freeTextInput" placeholder="薬剤名を入力">
                    <button type="button" onclick="addFreeText()">追加</button>
                </div>

                <div class="selected-pills" id="selectedPills">薬剤を選択または入力してください</div>

                <label for="memoText">状況メモ</label>
                <textarea id="memoText" name="memoText" placeholder="例:ドパミンとフロセミドを同一ルートで投与したいが可否を確認したい" required></textarea>

                <div class="form-row-2col">
                    <div>
                        <label for="urgency">緊急度</label>
                        <select id="urgency" name="urgency">
                            <option value="通常">通常</option>
                            <option value="要確認">要確認</option>
                            <option value="緊急">緊急</option>
                        </select>
                    </div>
                    <div>
                        <label for="submitter">提出者</label>
                        <input type="text" id="submitter" name="submitter" placeholder="例:田中 看護師">
                    </div>
                </div>

                <button type="submit" id="saveMemoBtn">メモとして保存</button>
            </form>
        </div>

        <c:forEach var="memo" items="${memoList}">
    <div class="memo-card ${memo.resolved ? 'resolved' : ''} urgency-${memo.urgency}">
        <div class="memo-drugs"><c:out value="${memo.drugNames}" /></div>
        <div class="memo-text"><c:out value="${memo.memoText}" /></div>
        <div class="memo-meta">
            <span>
                <span class="memo-tag"><c:out value="${memo.urgency}" /></span>
                <c:if test="${not empty memo.submitter}"> / <c:out value="${memo.submitter}" /></c:if>
                / <fmt:formatDate value="${memo.createdAt}" pattern="MM/dd HH:mm" />
                <c:if test="${memo.resolved}"> / 対応済み</c:if>
            </span>
                    <span class="memo-actions">
                        <form action="memo" method="post">
                            <input type="hidden" name="action" value="toggleResolved">
                            <input type="hidden" name="memoId" value="${memo.memoId}">
                            <input type="hidden" name="newState" value="${!memo.resolved}">
                            <button type="submit">${memo.resolved ? '未対応に戻す' : '対応済みにする'}</button>
                        </form>
                        <form action="memo" method="post" onsubmit="return confirm('このメモを削除しますか?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="memoId" value="${memo.memoId}">
                            <button type="submit">削除</button>
                        </form>
                    </span>
                </div>
            </div>
        </c:forEach>

    </div>

    <jsp:include page="tab-nav.jsp" />

    <script>
    let selectedDrugs = [];

    function toggleDrug(el) {
        const name = el.dataset.name;
        const idx = selectedDrugs.indexOf(name);
        if (idx === -1) {
            selectedDrugs.push(name);
            el.classList.add('selected');
        } else {
            selectedDrugs.splice(idx, 1);
            el.classList.remove('selected');
        }
        renderPills();
    }

    function addFreeText() {
        const input = document.getElementById('freeTextInput');
        const name = input.value.trim();
        if (name === '' || selectedDrugs.includes(name)) return;
        selectedDrugs.push(name);
        input.value = '';
        renderPills();
    }

    function removePill(name) {
        selectedDrugs = selectedDrugs.filter(d => d !== name);
        const chip = document.querySelector('.drug-chip[data-name="' + name + '"]');
        if (chip) chip.classList.remove('selected');
        renderPills();
    }

    function renderPills() {
        const container = document.getElementById('selectedPills');
        if (selectedDrugs.length === 0) {
            container.innerHTML = '薬剤を選択または入力してください';
        } else {
            container.innerHTML = selectedDrugs.map(name =>
                '<span class="pill">' + name +
                ' <span class="pill-remove" onclick="removePill(\'' + name.replace(/'/g, "\\'") + '\')">×</span></span>'
            ).join('');
        }
        document.getElementById('drugNamesInput').value = selectedDrugs.join(', ');
    }
    </script>
</body>
</html>