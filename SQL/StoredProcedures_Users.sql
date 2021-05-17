/*
	Create schema

IF SCHEMA_ID('web') IS NULL BEGIN	
	EXECUTE('CREATE SCHEMA [web]');
END
GO
*/

/*
	Create user to be used in the sample API solution

IF USER_ID('API_WS') IS NULL BEGIN	
	CREATE USER [API_WS] WITH PASSWORD = 'a987REALLY#$%TRONGpa44w0rd!';	
END

*/

/*
	Grant execute permission to created users

GRANT EXECUTE ON SCHEMA::[dbo] TO [API_WS];
GO

*/

/*
	Return details on a specific user
*/
CREATE OR ALTER PROCEDURE dbo.get_user
@Id INT
AS
SET NOCOUNT ON;
SELECT 
	[UserId],
    [RoleId],
    [Name], 
    [Email],
    [Password]
FROM 
	[dbo].[Users] 
WHERE 
	[UserID] = @Id
FOR JSON PATH
GO

/*
	Delete a specific customer
*/
CREATE OR ALTER PROCEDURE dbo.delete_user
@Id INT
AS
SET NOCOUNT ON;
DELETE FROM [dbo].[Users] WHERE UserId = @Id;
SELECT * FROM (SELECT UserID = @Id) D FOR JSON AUTO;
GO

/*
	Update (Patch) a specific user
*/
CREATE OR ALTER PROCEDURE dbo.patch_user
@Id INT,
@Json NVARCHAR(MAX)
AS
SET NOCOUNT ON;
WITH [source] AS 
(
	SELECT * FROM OPENJSON(@Json) WITH (
		[UserID] INT, 
		[RoleId]   INT,
		[Name]     VARCHAR (50),
		[Email]    VARCHAR (50),
		[Password] VARCHAR (20)		
	)
)
UPDATE
	t
SET
	t.[RoleId] = COALESCE(s.[RoleId], t.[RoleId]),
	t.[Name] = COALESCE(s.[Name], t.[Name]),
	t.[Email] = COALESCE(s.[Email], t.[Email]),
	t.[Password] = COALESCE(s.[Password], t.[Password])
FROM
	[dbo].[Users] t
INNER JOIN
	[source] s ON t.[UserID] = s.[UserID]
WHERE
	t.UserId = @Id;

EXEC dbo.get_user @Id;
GO

/*
	Create a new user
*/

CREATE OR ALTER PROCEDURE dbo.put_user
@Json NVARCHAR(MAX)
AS
SET NOCOUNT ON;
set identity_insert [dbo].[Users] on;
DECLARE @UserId INT = NEXT VALUE FOR [UserID];
Declare @Id INT;
WITH [source] AS 
(
	SELECT @Id AS UserID, * FROM OPENJSON(@Json) WITH (		
		[RoleId]   INT,
		[Name]     VARCHAR (50),
		[Email]    VARCHAR (50),
		[Password] VARCHAR (20)		
	)
)

INSERT INTO [dbo].[Users] 
(
	UserID, 
	RoleId,
	Name,
	Email,
	Password
)
SELECT
	@UserId, 
	RoleId,
	Name,
	Email,
	Password
FROM
	[source]
;

EXEC dbo.get_user @UserId;
GO

/*
	Return details for all users
*/
CREATE OR ALTER PROCEDURE dbo.get_users
AS
SET NOCOUNT ON;
-- Cast is needed to corretly inform the driver  
-- that output type is NVARCHAR(MAX)
-- to make sure it won't be truncated
SELECT CAST((
	SELECT 
		[UserID], 
		[RoleId],
		[Name], 
		[Email],
		[Password]
	FROM 
		[dbo].[Users] 
	FOR JSON PATH) AS NVARCHAR(MAX)) AS JsonResult
GO

/*
	Create Sequence for UserID
*/
CREATE SEQUENCE UserID
    AS INT
    START WITH 5
    INCREMENT BY 1;
