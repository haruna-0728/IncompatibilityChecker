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
import checker.bean.Incompatibility;
import checker.dao.DrugDAO;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DrugDAO dao = new DrugDAO();
        try {
            // 全薬剤を取得(検索キーワード空文字で全件ヒットさせる)
            List<Drug> drugList = dao.searchDrugs("");
            request.setAttribute("drugList", drugList);

            // 全配合禁忌情報を取得(JSで即時判定するため一括で渡す)
            List<Incompatibility> incompatibilityList = dao.getAllIncompatibilities();
            request.setAttribute("incompatibilityList", incompatibilityList);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "薬剤情報の取得に失敗しました。");
        }
        // search.jsp に処理を引き渡す(フォワード)
        request.getRequestDispatcher("/search.jsp").forward(request, response);
    }
}