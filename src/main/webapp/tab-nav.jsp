<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div class="nav">
    <a href="drip" class="nav-btn ${activeTab == 'drip' ? 'active' : ''}">
        <span class="nav-icon">💧</span>点滴
    </a>
    <a href="syringe" class="nav-btn ${activeTab == 'syringe' ? 'active' : ''}">
        <span class="nav-icon">💉</span>シリンジ
    </a>
    <a href="search" class="nav-btn ${activeTab == 'search' ? 'active' : ''}">
        <span class="nav-icon">⚠️</span>配合禁忌
    </a>
    <a href="memo" class="nav-btn ${activeTab == 'memo' ? 'active' : ''}">
        <span class="nav-icon">📝</span>メモ
    </a>
</div>