using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.OleDb;
using System.Data;
using System.Net.Mail;
using System.Text;


public partial class _Default : System.Web.UI.Page
{
    static string staticBD = "";


    protected void Page_Load(object sender, EventArgs e)
    {
        staticBD = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath("~/App_Data/") + "Score.mdb";
    }
    private void carregarList()
    {
        try
        {
            string table = "tScore";
            string query = "";
            query = "select * from " + table + " where Status='S' Order by Score Desc";

            OleDbDataAdapter oDataAdapter = new OleDbDataAdapter(query, staticBD);
            DataSet oDataSet = new DataSet();
            oDataSet.Reset();
            oDataAdapter.Fill(oDataSet, 0, 30, table);
            rptList.DataSource = oDataSet.Tables[table].DefaultView;
            rptList.DataBind();
        }
        catch (Exception e)
        {
        }
    }
    [System.Web.Services.WebMethod]
    public static string carregarRank()
    {
        string retorno = "";
        int qtdAtual = 0;
        int rows = 0;
        try
        {
            OleDbConnection con = new OleDbConnection(staticBD);
            string ComandoSql = "select * from tScore where Status='S' Order by Score Desc";
            OleDbDataAdapter da = new OleDbDataAdapter(ComandoSql, con);
            DataTable dtcadastro = new DataTable();
            da.Fill(dtcadastro);
            while (dtcadastro.Rows.Count > qtdAtual && qtdAtual < 30)
            {
                retorno += "<li>" +
                             "<p class='name'>" + Convert.ToString(dtcadastro.Rows[qtdAtual]["Nome"]) + "</p>" +
                             "<div class='score'>" + Convert.ToString(dtcadastro.Rows[qtdAtual]["Score"]) + " pts</div>" +
                           "</li>";
                qtdAtual++;
                rows++;
            }
            return retorno;
        }
        catch
        {
            return "";
        }
    }
    private void saveContato()
    {
        string conexao = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath("~/App_Data/") + "Score.mdb";
        OleDbConnection con = new OleDbConnection(conexao);
        OleDbCommand cmd = new OleDbCommand();
        cmd.CommandType = CommandType.Text;
        cmd.CommandText = "INSERT INTO tScore(Nome,Score,Data,Status)" +
        "Values('" + txtNome.Text.Replace("'", " ") + "','" + Request.Form["score"] + "',#" + DateTime.Today.Date.ToString("yyyy/MM/dd") + "#,'S')";
        cmd.Connection = con;
        con.Open();
        cmd.ExecuteNonQuery();
        con.Close();
    }
    protected void btnSalvar_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtNome.Text))
        {
            saveContato();
            carregarList();
            txtNome.Text = "";
            pnlSaveRank.Visible = false;
        }
        else
        {
            txtNome.Focus();
        }
    }
}