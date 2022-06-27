CREATE OR REPLACE PROCEDURE "ABC_UPDATE_CYC_END"("CYC_SK" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '

	var CYC_SK_var = CYC_SK;
try
{	
	var CYC_RUN_SK = `SELECT CYC_CUR_RUN_SK FROM iip_abc.ABC_CYC_CTRL_TBL WHERE CYC_SK =CYC_SK_var;`;
	var sqlStmt1 = snowflake.createStatement({sqlText: CYC_RUN_SK});
	var CYC_RUN_SK_var = sqlStmt1.execute();	
	
	var JOB_FAIL_COUNT = `SELECT COUNT(1) FROM iip_abc.ABC_JOB_CTRL_TBL J INNER JOIN iip_abc.ABC_STEP_CTRL_TBL S ON J.STEP_SK=S.STEP_SK INNER JOIN iip_abc.ABC_CYC_CTRL_TBL C ON S.CYC_SK=C.CYC_SK WHERE JOB_STS_CD=''F'' AND S.CYC_SK = CYC_SK_var AND J.ACTI_IND=''Y'';`;
	
	var sqlStmt2 = snowflake.createStatement({sqlText: JOB_FAIL_COUNT});
	var JOB_FAIL_COUNT_var = sqlStmt2.execute();
		
	if (JOB_FAIL_COUNT_var == 0)
	{
		BEGIN TRANSACTION;
		
		var my_sql_command1 = `UPDATE iip_abc.ABC_JOB_CTRL_TBL SET JOB_STS_CD = ''C'' WHERE JOB_SK IN (SELECT J.JOB_SK FROM iip_abc.ABC_JOB_CTRL_TBL J INNER JOIN iip_abc.ABC_STEP_CTRL_TBL S ON J.STEP_SK=S.STEP_SK INNER JOIN iip_abc.ABC_CYC_CTRL_TBL C ON S.CYC_SK=C.CYC_SK where C.CYC_SK = @CYC_SK AND J.ACTI_IND=''Y'');`;
		var statement1 = snowflake.createStatement(my_sql_command1);
		statement1.execute();
				
		var my_sql_command2 = `UPDATE iip_abc.ABC_STEP_CTRL_TBL SET STEP_STS_CD = ''C'',AUD_DT_TM = GETDATE() WHERE STEP_SK IN (SELECT STEP_SK FROM iip_abc.ABC_STEP_CTRL_TBL WHERE CYC_SK=CYC_SK_var);`;
		var statement2 = snowflake.createStatement(my_sql_command2);
		statement2.execute();		
		
		var my_sql_command3 = `UPDATE iip_abc.ABC_CYC_RUN_TBL SET CYC_STS_CD = ''S'', CYC_ENDDT_TM = GETDATE() WHERE CYC_RUN_SK = CYC_RUN_SK_var;`;
		var statement3 = snowflake.createStatement(my_sql_command3);
		statement3.execute();			
		
		var my_sql_command4 = `UPDATE iip_abc.ABC_CYC_CTRL_TBL SET CYC_STS_CD = ''C'',AUD_DT_TM = GETDATE() where CYC_SK = CYC_SK_var;`;
		var statement4 = snowflake.createStatement(my_sql_command4);
		statement4.execute();			
				
		COMMIT;
		
		return ''success'';
	}
	else
	{
		BEGIN TRANSACTION;
		
		var my_sql_command5 = `UPDATE iip_abc.ABC_CYC_RUN_TBL SET CYC_STS_CD = ''F'', CYC_ENDDT_TM = GETDATE() WHERE CYC_RUN_SK = CYC_RUN_SK_var;`;
		var statement5 = snowflake.createStatement(my_sql_command5);
		statement5.execute();	

		var my_sql_command6 = `UPDATE iip_abc.ABC_CYC_CTRL_TBL SET CYC_STS_CD = ''F'',AUD_DT_TM = GETDATE() where CYC_SK = CYC_SK_var;`;
		var statement6 = snowflake.createStatement(my_sql_command6);
		statement6.execute();
		
		COMMIT;		
		
		return ''success'';
	}
}	
catch (err)
		{
			  return "Failed" +err;
		}

';