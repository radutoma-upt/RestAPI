/*
	Create Sequence for RoleID
*/
CREATE SEQUENCE RoleID
    AS INT
    START WITH 5
    INCREMENT BY 1;

/*
	Return details on a specific role
*/
CREATE OR ALTER PROCEDURE dbo.get_role
@Id INT
AS
SET NOCOUNT ON;
SELECT 
	[RoleId],
    [Role],
    [IsAdmin],
    [IsDoctor],
    [IsUser]
FROM 
	[dbo].[Roles] 
WHERE 
	[RoleID] = @Id
FOR JSON PATH
GO

/*
	Delete a specific role
*/
CREATE OR ALTER PROCEDURE dbo.delete_role
@Id INT
AS
SET NOCOUNT ON;
DELETE FROM [dbo].[Roles] WHERE RoleId = @Id;
SELECT * FROM (SELECT RoleID = @Id) D FOR JSON AUTO;
GO

/*
	Update (Patch) a specific role
*/
CREATE OR ALTER PROCEDURE dbo.patch_role
@Id INT,
@Json NVARCHAR(MAX)
AS
SET NOCOUNT ON;
WITH [source] AS 
(
	SELECT * FROM OPENJSON(@Json) WITH (
		[RoleId]   INT,
		[Role]     VARCHAR (50),
		[IsAdmin]  BIT,
		[IsDoctor] BIT,
		[IsUser]   BIT		
	)
)
UPDATE
	t
SET
	t.[Role] = COALESCE(s.[Role], t.[Role]),
	t.[IsAdmin] = COALESCE(s.[IsAdmin], t.[IsAdmin]),
	t.[IsDoctor] = COALESCE(s.[IsDoctor], t.[IsDoctor]),
	t.[IsUser] = COALESCE(s.[IsUser], t.[IsUser])
FROM
	[dbo].[Roles] t
INNER JOIN
	[source] s ON t.[RoleID] = s.[RoleID]
WHERE
	t.RoleId = @Id;

EXEC dbo.get_role @Id;
GO

/*
	Create a new role
*/

CREATE OR ALTER PROCEDURE dbo.put_role
@Json NVARCHAR(MAX)
AS
SET NOCOUNT ON;
set identity_insert [dbo].[Roles] on;
DECLARE @RoleId INT = NEXT VALUE FOR [RoleID];
Declare @Id INT;
WITH [source] AS 
(
	SELECT @Id AS RoleID, * FROM OPENJSON(@Json) WITH (		
		[Role]     VARCHAR (50),
		[IsAdmin]  BIT,
		[IsDoctor] BIT,
		[IsUser]   BIT		
	)
)

INSERT INTO [dbo].[Roles] 
(
	RoleID, 
	Role,
    IsAdmin,
    IsDoctor,
    IsUser
)
SELECT
	@RoleId, 
	Role,
    IsAdmin,
    IsDoctor,
    IsUser
FROM
	[source]
;

EXEC dbo.get_role @RoleId;
GO

/*
	Return details for all roles
*/
CREATE OR ALTER PROCEDURE dbo.get_roles
AS
SET NOCOUNT ON;
-- Cast is needed to corretly inform the driver  
-- that output type is NVARCHAR(MAX)
-- to make sure it won't be truncated
SELECT CAST((
	SELECT 
		[RoleId],
		[Role],
		[IsAdmin],
		[IsDoctor],
		[IsUser]
	FROM 
		[dbo].[Roles] 
	FOR JSON PATH) AS NVARCHAR(MAX)) AS JsonResult
GO

