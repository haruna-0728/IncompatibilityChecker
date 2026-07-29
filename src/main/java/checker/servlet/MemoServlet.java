package checker.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import checker.bean.Drug;
import checker.bean.MemoEntry;
import checker.dao.DrugDAO;
import checker.dao.MemoDAO;

@WebServlet("/memo")
public class MemoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        MemoDAO memoDao = new MemoDAO();
        DrugDAO drugDao = new DrugDAO();

        try {
            // メモ一覧を取得
            List<MemoEntry> memoList = memoDao.getAllMemos();
            request.setAttribute("memoList", memoList);

            // 薬剤チップ表示用に、薬剤一覧も取得
            List<Drug> drugList = drugDao.searchDrugs("");
            request.setAttribute("drugList", drugList);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "データの取得に失敗しました。");
        }
        request.getRequestDispatcher("/memo.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        MemoDAO dao = new MemoDAO();

        try {
            if ("add".equals(action)) {
                MemoEntry memo = new MemoEntry();
                memo.setDrugNames(request.getParameter("drugNames"));
                memo.setMemoText(request.getParameter("memoText"));
                memo.setUrgency(request.getParameter("urgency"));
                memo.setSubmitter(request.getParameter("submitter"));
                dao.insertMemo(memo);

            } else if ("delete".equals(action)) {
                int memoId = Integer.parseInt(request.getParameter("memoId"));
                dao.deleteMemo(memoId);

            } else if ("toggleResolved".equals(action)) {
                int memoId = Integer.parseInt(request.getParameter("memoId"));
                boolean newState = Boolean.parseBoolean(request.getParameter("newState"));
                dao.updateResolved(memoId, newState);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 処理後は一覧表示(/memo)へリダイレクト(再読み込みでの二重送信を防ぐ)
        response.sendRedirect("memo");
    }
}