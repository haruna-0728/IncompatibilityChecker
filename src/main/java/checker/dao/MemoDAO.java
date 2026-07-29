package checker.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import checker.bean.MemoEntry;

public class MemoDAO {
    private static final String URL = "jdbc:mysql://localhost:3306/incompatibility_db";
    private static final String USER = "root";
    private static final String PASS = System.getenv("DB_PASSWORD");
    // 以下、既存のgetConnectionなどはそのまま
	    																																																																																																																																																																																																																																																																																																																																																								
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBCドライバが見つかりません", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // メモを新規登録する
    public void insertMemo(MemoEntry memo) throws SQLException {
        String sql = "INSERT INTO memo_entries (drug_names, memo_text, urgency, submitter) "
                   + "VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memo.getDrugNames());
            pstmt.setString(2, memo.getMemoText());
            pstmt.setString(3, memo.getUrgency());
            pstmt.setString(4, memo.getSubmitter());
            pstmt.executeUpdate();
        }
    }

    // メモを全件取得(未対応を上に、新しい順)
    public List<MemoEntry> getAllMemos() throws SQLException {
        List<MemoEntry> list = new ArrayList<>();
        String sql = "SELECT memo_id, drug_names, memo_text, urgency, submitter, resolved, created_at "
                   + "FROM memo_entries ORDER BY resolved ASC, created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                MemoEntry memo = new MemoEntry();
                memo.setMemoId(rs.getInt("memo_id"));
                memo.setDrugNames(rs.getString("drug_names"));
                memo.setMemoText(rs.getString("memo_text"));
                memo.setUrgency(rs.getString("urgency"));
                memo.setSubmitter(rs.getString("submitter"));
                memo.setResolved(rs.getBoolean("resolved"));
                memo.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(memo);
            }
        }
        return list;
    }

    // メモを削除する
    public void deleteMemo(int memoId) throws SQLException {
        String sql = "DELETE FROM memo_entries WHERE memo_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, memoId);
            pstmt.executeUpdate();
        }
    }

    // 対応済み状態を切り替える
    public void updateResolved(int memoId, boolean resolved) throws SQLException {
        String sql = "UPDATE memo_entries SET resolved = ? WHERE memo_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBoolean(1, resolved);
            pstmt.setInt(2, memoId);
            pstmt.executeUpdate();
        }
    }
}