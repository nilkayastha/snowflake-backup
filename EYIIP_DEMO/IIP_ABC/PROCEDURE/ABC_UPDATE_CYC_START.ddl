CREATE OR REPLACE PROCEDURE "ABC_UPDATE_CYC_START"("CYC_SK" VARCHAR(16777216), "FORCE_IND" VARCHAR(1))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var CYC_SK_var = CYC_SK;
var FORCE_IND_var = FORCE_IND;

try
{
	var CYC_STS_CD = `SELECT CYC_STS_CD FROM iip_abc.ABC_CYC_CTRL_TBL WHERE CYC_SK= CYC_SK_var;`;
	var sqlStmt1 = snowflake.createStatement({sqlText: CYC_STS_CD});
	var CYC_STS_CD_var = sqlStmt1.execute();
	
	IF (CYC_STS_CD_var == ''C'') OR (FORCE_IND_var ==''Y'')
	{
	
		BEGIN TRANSACTION;
		
		var CYC_RUN_SK = `SELECT SEQ_CYC_RUN_SK.NEXTVAL;`;
		var sqlStmt2 = snowflake.createStatement({sqlText: CYC_RUN_SK});
		var CYC_RUN_SK_var = sqlStmt2.execute();

			
		var insrt_stmt= `INSERT INTO iip_abc.ABC_CYC_RUN_TBL VALUES	(CYC_RUN_SK_var , CYC_SK_var, GETDATE(), NULL, ''I'', GETDATE());`;
			var sqlStmt3 = snowflake.createStatement({sqlText: insrt_stmt});
			var INSRT_STMT_RESLT = sqlStmt3.execute();
		
		var update_stmt = `UPDATE iip_abc.ABC_CYC_CTRL_TBL SET CYC_STS_CD = ''I'', CYC_CUR_RUN_SK = CYC_RUN_SK_var WHERE CYC_SK = CYC_SK_var;`;
			var sqlStmt4 = snowflake.createStatement({sqlText: update_stmt});
			ar update_stmt_reslt = sqlStmt4.execute();
	
		COMMIT;
		return ''success'';
	}
	
}
catch (err)
		{
			  return "Failed" +err;
		}

';