use [carpark]
GO

/****** Object:  Table [dbo].[cars]    Script Date: 22.06.2023 4:59:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[cars](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[legal_number] [nvarchar](250) NULL,
	[model] [int] NOT NULL,
	[wear] [int] NOT NULL,
	[birth_year] [int] NOT NULL,
	[maintenance] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dbo].[cars_hist] )
)
GO

ALTER TABLE [dbo].[cars]  WITH CHECK ADD  CONSTRAINT [FK_cars_auto_model] FOREIGN KEY([model])
REFERENCES [dbo].[cars_model] ([id])
GO

ALTER TABLE [dbo].[cars] CHECK CONSTRAINT [FK_cars_auto_model]
GO

