-- Create a server-wide login authenticated by a password
CREATE LOGIN foodmart WITH PASSWORD = 'F00dmartpass'
GO
CREATE DATABASE foodmart
GO
USE foodmart
GO
-- Within 'foodmart', create a user corresponding to the server-wide login
CREATE USER foodmart
GO
-- Allow everything
GRANT CONTROL ON DATABASE::foodmart TO foodmart
GO
