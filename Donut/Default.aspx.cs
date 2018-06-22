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
using System.Security.Cryptography;
using System.Configuration;


public partial class _Default : System.Web.UI.Page
{
    static string staticBD = "";
    static string staticBDCripto = "";


    protected void Page_Load(object sender, EventArgs e)
    {
        staticBD = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath("~/App_Data/") + "Score.mdb";
        staticBDCripto = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath("~/App_Data/") + "Cripto.mdb";

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
        string score = selectCripto(Request.Form["score"]);
        if (!string.IsNullOrEmpty(score))
        {
            score = Decrypt(score);
            deleteCripto(Request.Form["score"]);
            string conexao = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath("~/App_Data/") + "Score.mdb";
            OleDbConnection con = new OleDbConnection(conexao);
            OleDbCommand cmd = new OleDbCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = "INSERT INTO tScore(Nome,Score,Data,Status)" +
            "Values('" + txtNome.Text.Replace("'", " ") + "','" + score + "',#" + DateTime.Today.Date.ToString("yyyy/MM/dd") + "#,'S')";
            cmd.Connection = con;
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();
        }
        else
        {
            ScriptManager.RegisterClientScriptBlock(this.Page, this.GetType(), "alertCracker();", "alert('Não foi possível computar seus pontos, tente novamente!')", true);
        }
        
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






    [System.Web.Services.WebMethod]
    public static string genereteScore(string toEncrypt)
    {
        bool useHashing = true;
        byte[] keyArray;
        byte[] toEncryptArray = UTF8Encoding.UTF8.GetBytes(toEncrypt);

        System.Configuration.AppSettingsReader settingsReader =
                                            new AppSettingsReader();
        // Get the key from config file

        string key = "@d0XmyNET#$";
        /*(string)settingsReader.GetValue("@d0XmyNET#$", typeof(String));
            <appSettings>
                <add key="hashKey" value=""/>
            </appSettings>*/


        //If hashing use get hashcode regards to your key
        if (useHashing)
        {
            MD5CryptoServiceProvider hashmd5 = new MD5CryptoServiceProvider();
            keyArray = hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(key));
            //Always release the resources and flush data
            // of the Cryptographic service provide. Best Practice

            hashmd5.Clear();
        }
        else
            keyArray = UTF8Encoding.UTF8.GetBytes(key);

        TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
        //set the secret key for the tripleDES algorithm
        tdes.Key = keyArray;
        //mode of operation. there are other 4 modes.
        //We choose ECB(Electronic code Book)
        tdes.Mode = CipherMode.ECB;
        //padding mode(if any extra byte added)

        tdes.Padding = PaddingMode.PKCS7;

        ICryptoTransform cTransform = tdes.CreateEncryptor();
        //transform the specified region of bytes array to resultArray
        byte[] resultArray =
          cTransform.TransformFinalBlock(toEncryptArray, 0,
          toEncryptArray.Length);
        //Release resources held by TripleDes Encryptor
        tdes.Clear();
        //Return the encrypted data into unreadable string format
        return saveCripto(Convert.ToBase64String(resultArray, 0, resultArray.Length));
    }

    [System.Web.Services.WebMethod]
    public static string Decrypt(string cipherString)
    {
        bool useHashing = true;
        byte[] keyArray;
        //get the byte code of the string

        byte[] toEncryptArray = Convert.FromBase64String(cipherString);

        System.Configuration.AppSettingsReader settingsReader = new AppSettingsReader();
        //Get your key from config file to open the lock!
        string key = "@d0XmyNET#$";
        /*(string)settingsReader.GetValue("@d0XmyNET#$", typeof(String));
            <appSettings>
                <add key="hashKey" value=""/>
            </appSettings>*/

        if (useHashing)
        {
            //if hashing was used get the hash code with regards to your key
            MD5CryptoServiceProvider hashmd5 = new MD5CryptoServiceProvider();
            keyArray = hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(key));
            //release any resource held by the MD5CryptoServiceProvider

            hashmd5.Clear();
        }
        else
        {
            //if hashing was not implemented get the byte code of the key
            keyArray = UTF8Encoding.UTF8.GetBytes(key);
        }

        TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
        //set the secret key for the tripleDES algorithm
        tdes.Key = keyArray;
        //mode of operation. there are other 4 modes. 
        //We choose ECB(Electronic code Book)

        tdes.Mode = CipherMode.ECB;
        //padding mode(if any extra byte added)
        tdes.Padding = PaddingMode.PKCS7;

        ICryptoTransform cTransform = tdes.CreateDecryptor();
        byte[] resultArray = cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
        //Release resources held by TripleDes Encryptor                
        tdes.Clear();
        //return the Clear decrypted TEXT
        return UTF8Encoding.UTF8.GetString(resultArray);
    }

    [System.Web.Services.WebMethod]
    public static string saveCripto(string value)
    {
        string id = DateTime.Now.ToString("ddMMyyyyTHHmmss");
        while(!string.IsNullOrEmpty(selectCripto(id))){
            id = DateTime.Now.ToString("ddMMyyyyTHHmmss");
        }
        
        OleDbConnection con = new OleDbConnection(staticBDCripto);
        OleDbCommand cmd = new OleDbCommand();
        cmd.CommandType = CommandType.Text;
        cmd.CommandText = "INSERT INTO tCripto(ID,cripto)" +
        "Values('" + id + "','" + value + "')";
        cmd.Connection = con;
        con.Open();
        cmd.ExecuteNonQuery();
        con.Close();

        return id;
    }

    [System.Web.Services.WebMethod]
    public static string selectCripto(string value)
    {
        OleDbConnection con = new OleDbConnection(staticBDCripto);
        string ComandoSql = "select * from tCripto where ID='" + value + "'";
        OleDbDataAdapter da = new OleDbDataAdapter(ComandoSql, con);
        DataTable dtcadastro = new DataTable();
        da.Fill(dtcadastro);
        if (dtcadastro.Rows.Count > 0)
        {
            return Convert.ToString(dtcadastro.Rows[0]["cripto"]);
        }
        return null;
    }

    public static void deleteCripto(string value)
    {
        OleDbConnection con = new OleDbConnection(staticBDCripto);
        OleDbCommand cmd = new OleDbCommand();
        cmd.CommandType = CommandType.Text;
        cmd.CommandText = "delete from tCripto where ID = '" + value + "'";
        cmd.Connection = con;
        con.Open();
        cmd.ExecuteNonQuery();
        con.Close();
    }
}