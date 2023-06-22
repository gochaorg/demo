USE [test1]
GO

/****** Object:  Table [dbo].[waybills]    Script Date: 22.06.2023 5:00:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[waybills](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[driver] [int] NOT NULL,
	[dispatcher] [int] NOT NULL,
	[car] [int] NOT NULL,
	[outcome_date] [datetime2](7) NOT NULL,
	[income_date] [datetime2](7) NOT NULL,
	[wear] [int] NOT NULL,
	[fuel_cons] [int] NOT NULL,
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
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dbo].[waybills_hist] )
)
GO

ALTER TABLE [dbo].[waybills]  WITH CHECK ADD  CONSTRAINT [FK_waybills_car] FOREIGN KEY([car])
REFERENCES [dbo].[cars] ([id])
GO

ALTER TABLE [dbo].[waybills] CHECK CONSTRAINT [FK_waybills_car]
GO

ALTER TABLE [dbo].[waybills]  WITH CHECK ADD  CONSTRAINT [FK_waybills_dispatcher] FOREIGN KEY([dispatcher])
REFERENCES [dbo].[dispatchers] ([id])
GO

ALTER TABLE [dbo].[waybills] CHECK CONSTRAINT [FK_waybills_dispatcher]
GO

ALTER TABLE [dbo].[waybills]  WITH CHECK ADD  CONSTRAINT [FK_waybills_driver] FOREIGN KEY([driver])
REFERENCES [dbo].[drivers] ([id])
GO

ALTER TABLE [dbo].[waybills] CHECK CONSTRAINT [FK_waybills_driver]
GO

