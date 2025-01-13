CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;

CREATE TABLE "Countries" (
    "CountryId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "Title" character varying(50) NOT NULL,
    CONSTRAINT "PK_Countries" PRIMARY KEY ("CountryId")
);

CREATE TABLE "Devices" (
    "DeviceId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "DeviceToken" character varying(255) NOT NULL,
    CONSTRAINT "PK_Devices" PRIMARY KEY ("DeviceId")
);

CREATE TABLE "Disciplines" (
    "DisciplineId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "Title" character varying(30) NOT NULL,
    CONSTRAINT "PK_Disciplines" PRIMARY KEY ("DisciplineId")
);

CREATE TABLE "Grades" (
    "GradeId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "GradeNumber" integer NOT NULL,
    CONSTRAINT "PK_Grades" PRIMARY KEY ("GradeId")
);

CREATE TABLE "Institutions" (
    "InstitutionId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "Title" character varying(50) NOT NULL,
    "Address" character varying(150) NOT NULL,
    CONSTRAINT "PK_Institutions" PRIMARY KEY ("InstitutionId")
);

CREATE TABLE "InstitutionTypes" (
    "InstitutionTypeId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "Title" character varying(20) NOT NULL,
    CONSTRAINT "PK_InstitutionTypes" PRIMARY KEY ("InstitutionTypeId")
);

CREATE TABLE "Languages" (
    "LanguageId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "Title" character varying(30) NOT NULL,
    CONSTRAINT "PK_Languages" PRIMARY KEY ("LanguageId")
);

CREATE TABLE "Roles" (
    "RoleId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "Title" character varying(20) NOT NULL,
    CONSTRAINT "PK_Roles" PRIMARY KEY ("RoleId")
);

CREATE TABLE "Cities" (
    "CityId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "Title" character varying(30) NOT NULL,
    "CountryId" uuid NOT NULL,
    CONSTRAINT "PK_Cities" PRIMARY KEY ("CityId"),
    CONSTRAINT "FK_Cities_Countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES "Countries" ("CountryId") ON DELETE CASCADE
);

CREATE TABLE "InstitutionTypesInstitutions" (
    "InstitutionTypeId" uuid NOT NULL,
    "InstitutionId" uuid NOT NULL,
    CONSTRAINT "PK_InstitutionTypesInstitutions" PRIMARY KEY ("InstitutionTypeId", "InstitutionId"),
    CONSTRAINT "FK_InstitutionTypesInstitutions_Institutions_InstitutionId" FOREIGN KEY ("InstitutionId") REFERENCES "Institutions" ("InstitutionId") ON DELETE CASCADE,
    CONSTRAINT "FK_InstitutionTypesInstitutions_InstitutionTypes_InstitutionTy~" FOREIGN KEY ("InstitutionTypeId") REFERENCES "InstitutionTypes" ("InstitutionTypeId") ON DELETE CASCADE
);

CREATE TABLE "Users" (
    "UserId" uuid NOT NULL,
    "Email" text NOT NULL,
    "IsGoogleSignedIn" boolean NOT NULL DEFAULT FALSE,
    "IsPasswordSet" boolean NOT NULL DEFAULT FALSE,
    "PasswordHash" bytea NOT NULL,
    "PasswordSalt" bytea NOT NULL,
    "PasswordResetCode" character(6) NULL,
    "VerificationCode" character varying(10) NULL,
    "IsCreatedAccount" boolean NOT NULL DEFAULT FALSE,
    "IsVerified" boolean NOT NULL DEFAULT FALSE,
    "IsInstitutionVerified" boolean NOT NULL DEFAULT FALSE,
    "FirstName" character varying(40) NULL DEFAULT '',
    "LastName" character varying(40) NULL DEFAULT '',
    "IsATeacher" boolean NULL,
    "IsAnExpert" boolean NULL,
    "InstitutionId" uuid NULL,
    "CityId" uuid NULL,
    "CountryId" uuid NULL,
    "Rating" numeric(3,2) NOT NULL DEFAULT 0.0,
    "Description" character varying(300) NULL DEFAULT '',
    "ImageUrl" character varying(255) NULL DEFAULT '',
    "BannerImageUrl" character varying(255) NULL DEFAULT '',
    "RegisteredAt" timestamp with time zone NOT NULL DEFAULT (now()),
    "CreatedAt" timestamp with time zone NULL DEFAULT (now()),
    "VerifiedAt" timestamp with time zone NULL,
    "LastOnlineAt" timestamp with time zone NOT NULL DEFAULT (now()),
    "DeletedAt" timestamp with time zone NULL,
    CONSTRAINT "PK_Users" PRIMARY KEY ("UserId"),
    CONSTRAINT "FK_Users_Cities_CityId" FOREIGN KEY ("CityId") REFERENCES "Cities" ("CityId") ON DELETE SET NULL,
    CONSTRAINT "FK_Users_Countries_CountryId" FOREIGN KEY ("CountryId") REFERENCES "Countries" ("CountryId") ON DELETE SET NULL,
    CONSTRAINT "FK_Users_Institutions_InstitutionId" FOREIGN KEY ("InstitutionId") REFERENCES "Institutions" ("InstitutionId") ON DELETE SET NULL
);

CREATE TABLE "Classes" (
    "ClassId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Title" character varying(40) NOT NULL,
    "GradeId" uuid NOT NULL,
    "ImageUrl" character varying(200) NULL DEFAULT '',
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT (now()),
    "DisciplineId" uuid NOT NULL,
    CONSTRAINT "PK_Classes" PRIMARY KEY ("ClassId"),
    CONSTRAINT "FK_Classes_Disciplines_DisciplineId" FOREIGN KEY ("DisciplineId") REFERENCES "Disciplines" ("DisciplineId") ON DELETE CASCADE,
    CONSTRAINT "FK_Classes_Grades_GradeId" FOREIGN KEY ("GradeId") REFERENCES "Grades" ("GradeId") ON DELETE CASCADE,
    CONSTRAINT "FK_Classes_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "Notifications" (
    "NotificationId" uuid NOT NULL,
    "UserReceiverId" uuid NOT NULL,
    "Type" integer NOT NULL,
    "Status" integer NOT NULL,
    "Message" text NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "ReadAt" timestamp with time zone NULL,
    "IsDeleted" boolean NOT NULL,
    "DeletedAt" timestamp with time zone NULL,
    CONSTRAINT "PK_Notifications" PRIMARY KEY ("NotificationId"),
    CONSTRAINT "FK_Notifications_Users_UserReceiverId" FOREIGN KEY ("UserReceiverId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "UserDevices" (
    "UserId" uuid NOT NULL,
    "DeviceId" uuid NOT NULL,
    "RefreshToken" text NULL,
    "IsActive" boolean NOT NULL,
    "LastActive" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_UserDevices" PRIMARY KEY ("UserId", "DeviceId"),
    CONSTRAINT "FK_UserDevices_Devices_DeviceId" FOREIGN KEY ("DeviceId") REFERENCES "Devices" ("DeviceId") ON DELETE CASCADE,
    CONSTRAINT "FK_UserDevices_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "UserDisciplines" (
    "DisciplineId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    CONSTRAINT "PK_UserDisciplines" PRIMARY KEY ("UserId", "DisciplineId"),
    CONSTRAINT "FK_UserDisciplines_Disciplines_DisciplineId" FOREIGN KEY ("DisciplineId") REFERENCES "Disciplines" ("DisciplineId") ON DELETE CASCADE,
    CONSTRAINT "FK_UserDisciplines_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "UserGrades" (
    "GradeId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    CONSTRAINT "PK_UserGrades" PRIMARY KEY ("UserId", "GradeId"),
    CONSTRAINT "FK_UserGrades_Grades_GradeId" FOREIGN KEY ("GradeId") REFERENCES "Grades" ("GradeId") ON DELETE CASCADE,
    CONSTRAINT "FK_UserGrades_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "UserLanguages" (
    "UserId" uuid NOT NULL,
    "LanguageId" uuid NOT NULL,
    CONSTRAINT "PK_UserLanguages" PRIMARY KEY ("UserId", "LanguageId"),
    CONSTRAINT "FK_UserLanguages_Languages_LanguageId" FOREIGN KEY ("LanguageId") REFERENCES "Languages" ("LanguageId") ON DELETE CASCADE,
    CONSTRAINT "FK_UserLanguages_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "UserRoles" (
    "UserId" uuid NOT NULL,
    "RoleId" uuid NOT NULL,
    CONSTRAINT "PK_UserRoles" PRIMARY KEY ("UserId", "RoleId"),
    CONSTRAINT "FK_UserRoles_Roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES "Roles" ("RoleId") ON DELETE CASCADE,
    CONSTRAINT "FK_UserRoles_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "ClassLanguages" (
    "LanguageId" uuid NOT NULL,
    "ClassId" uuid NOT NULL,
    CONSTRAINT "PK_ClassLanguages" PRIMARY KEY ("LanguageId", "ClassId"),
    CONSTRAINT "FK_ClassLanguages_Classes_ClassId" FOREIGN KEY ("ClassId") REFERENCES "Classes" ("ClassId") ON DELETE CASCADE,
    CONSTRAINT "FK_ClassLanguages_Languages_LanguageId" FOREIGN KEY ("LanguageId") REFERENCES "Languages" ("LanguageId") ON DELETE CASCADE
);

CREATE TABLE "Invitations" (
    "InvitationId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "UserSenderId" uuid NOT NULL,
    "UserRecipientId" uuid NOT NULL,
    "ClassSenderId" uuid NOT NULL,
    "ClassRecipientId" uuid NULL,
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT (now()),
    "DateOfInvitation" timestamp with time zone NOT NULL,
    "Type" integer NOT NULL,
    "Status" text NOT NULL,
    "InvitationText" character varying(255) NULL,
    CONSTRAINT "PK_Invitations" PRIMARY KEY ("InvitationId"),
    CONSTRAINT "FK_Invitations_Classes_ClassRecipientId" FOREIGN KEY ("ClassRecipientId") REFERENCES "Classes" ("ClassId") ON DELETE CASCADE,
    CONSTRAINT "FK_Invitations_Classes_ClassSenderId" FOREIGN KEY ("ClassSenderId") REFERENCES "Classes" ("ClassId") ON DELETE CASCADE,
    CONSTRAINT "FK_Invitations_Users_UserRecipientId" FOREIGN KEY ("UserRecipientId") REFERENCES "Users" ("UserId") ON DELETE CASCADE,
    CONSTRAINT "FK_Invitations_Users_UserSenderId" FOREIGN KEY ("UserSenderId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

CREATE TABLE "Feedbacks" (
    "FeedbackId" uuid NOT NULL DEFAULT (gen_random_uuid()),
    "InvitationId" uuid NOT NULL,
    "UserFeedbackSenderId" uuid NOT NULL,
    "UserFeedbackReceiverId" uuid NOT NULL,
    "WasTheJointLesson" boolean NOT NULL,
    "ReasonForNotConducting" character varying(255) NULL,
    "FeedbackText" character varying(255) NULL,
    "Rating" SMALLINT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Feedbacks" PRIMARY KEY ("FeedbackId"),
    CONSTRAINT "FK_Feedbacks_Invitations_InvitationId" FOREIGN KEY ("InvitationId") REFERENCES "Invitations" ("InvitationId") ON DELETE CASCADE,
    CONSTRAINT "FK_Feedbacks_Users_UserFeedbackReceiverId" FOREIGN KEY ("UserFeedbackReceiverId") REFERENCES "Users" ("UserId") ON DELETE CASCADE,
    CONSTRAINT "FK_Feedbacks_Users_UserFeedbackSenderId" FOREIGN KEY ("UserFeedbackSenderId") REFERENCES "Users" ("UserId") ON DELETE CASCADE
);

INSERT INTO "Countries" ("CountryId", "Title")
VALUES ('14d8a226-6f56-4193-a654-0db8d58ed38a', 'Belarus');
INSERT INTO "Countries" ("CountryId", "Title")
VALUES ('7feac47d-5c1c-454d-b2ef-c60c6c75ceab', 'Russia');

INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('015fa99f-240f-417c-be8e-d7c439121174', 'Chemistry');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('12a5942f-9853-454c-baf7-96e232389935', 'Russian language');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('1752f8ea-2cc0-4068-8a2c-d4a1e640503f', 'German as a foreign language');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('17804eaa-5545-43ff-999a-322b3eeae281', 'Technology');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('2885cc04-9a6d-4e27-b195-873fb9ed6006', 'Mathematics');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('295166c1-e0fc-405e-ab7f-ce8ccfb98f9f', 'Physics');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('438b29e7-7009-44a2-8746-c33e1bc4fd05', 'Vacation education');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('4c616c7f-ab5d-4813-a751-3b2a18470971', 'Crafts');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('5533de6f-51dc-4c9b-b38e-5f10f03ad259', 'Project-based learning');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('5e1d1e46-7be8-4f67-8041-f52850f08d6f', 'History');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('6e609695-3277-4572-82fb-d4f8f7ddaf47', 'Astronomy');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('71d49552-0957-44a8-96ae-dd0ec109b7a9', 'Computer science');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('73944100-895d-4adf-9932-657d43476888', 'French as a foreign language');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('78bd3361-7a78-4dcc-98e9-9c5071facfee', 'Fine arts');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('89e95ed1-8088-4340-ab37-1386de70fdd8', 'Geography');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('9e12b5c1-2aa5-4568-940e-db882e03e2e5', 'Music');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('a4a3b902-14e9-41c5-bdca-19440b896845', 'Chinese as a foreign language');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('bc71607b-a8e3-4bc8-9e59-23ce339a454c', 'Italian as a foreign language');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('c8f9ca19-5b8d-43d0-804c-225ef2c27050', 'Natural science');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('cec8688b-4d51-4bad-b8b1-561203ad02f6', 'Economics');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('d4216af8-f6de-4b10-b3a0-b8b5ec2357b7', 'Russian literature');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('d9f732c2-370f-4536-8385-e9028ceb0f00', 'English as a foreign language');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('da2a943c-8ea5-4ada-a6b4-12b14a9ac641', 'Regional studies');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('e3fc8b5a-bc11-4ab4-bb40-d7503d7de16a', 'World art');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('e843df9f-97aa-484e-8695-42628efe3c10', 'Spanish as a foreign language');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('eb196ec4-35b4-463c-b29d-a41dbec7c3b3', 'Social science');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('f243d0b6-9462-4190-ba6d-b2b54433d512', 'Biology');
INSERT INTO "Disciplines" ("DisciplineId", "Title")
VALUES ('ff71d771-57a7-437a-a6ad-d81b7df8849c', 'Cultural exchange');

INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('1253bf02-ead4-4b35-932e-e8bd142c6787', 12);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('26da8ff8-4eae-4b1d-af1a-0e5aecdf6ff0', 6);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('3bf4b91d-cf09-4b4d-8f2f-1e967f36ef23', 2);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', 8);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('791daf36-d1c5-4453-9bfe-2f509894f43f', 1);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 9);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('8e2f9809-ca64-4c0b-be9d-93dcbadf32a7', 5);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('91b147da-00e6-403f-9656-3c1ce0ea1f7b', 10);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('a96f0ada-2a48-4792-a13f-0875c17a54ba', 4);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('ada13721-da9a-48ef-bb10-99c2ac3ab1a5', 3);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('b929ed6f-9fd2-44ef-bc38-7c291ac994bf', 11);
INSERT INTO "Grades" ("GradeId", "GradeNumber")
VALUES ('d61fd4f1-352a-4e7f-a0c2-5d7ada20570e', 7);

INSERT INTO "InstitutionTypes" ("InstitutionTypeId", "Title")
VALUES ('43cee2fb-f464-4f21-8b1b-a1edc6539a15', 'School');
INSERT INTO "InstitutionTypes" ("InstitutionTypeId", "Title")
VALUES ('4f3a52f2-2371-4419-a7cd-cd84ebe6f7f0', 'College');
INSERT INTO "InstitutionTypes" ("InstitutionTypeId", "Title")
VALUES ('cf2df748-eb5a-4291-a7f5-4a117560e937', 'Gymnasium');
INSERT INTO "InstitutionTypes" ("InstitutionTypeId", "Title")
VALUES ('f102524a-ed03-4bd1-a166-a6b135ebb79d', 'Lyceum');

INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('02c391a4-0fd2-4642-bb90-f1cbb272a16d', 'Belarus, Minsk', 'OdMJLItnQFeHWd');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('0333432f-526e-47bd-b204-9c0bf9a1d828', 'Russia, Moscow', 'KXsWczkuGvKojJ');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('0ac9bbed-525a-43e0-bf61-ce6bf4df3cc0', 'Belarus, Minsk', 'JQCiOLdQfjgzVv');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('17d0068c-37d1-4def-8ef9-e55a1f5a780e', 'Belarus, Minsk', 'xTugBgGmOSdwyR');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('2078ec21-1fe6-46fc-91c9-c50b24811b9f', 'Belarus, Minsk', 'rwIGOvMXIeVVWf');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('215fe3af-f32f-46ed-adb5-8841653a9794', 'Belarus, Minsk', 'kFFjFVKTTVTcCY');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('2617d600-be07-410e-967a-5e4f94603089', 'Russia, Moscow', 'RXeGurXKgSgrtf');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('28211f94-f503-4249-b075-efd5712697c4', 'Belarus, Minsk', 'dvIGmgQPVsHxBA');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('2f1cce1a-240d-44ee-861e-f94ef52c01a3', 'Belarus, Minsk', 'cTaUXWfEjBXJrD');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('3a046f78-4ba5-437e-b538-8add4522d6c1', 'Belarus, Minsk', 'ingyCWWOxHlEqO');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('3bc911ff-aedb-41b4-8981-1746e0e76627', 'Belarus, Minsk', 'AwNzJFYGXZWLhN');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('41fa205f-8b50-4a04-bece-4e83d770d4f0', 'Belarus, Minsk', 'LVjmoPhUMIRzBj');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('45c00ee1-dd5e-458a-b2d9-cb12c1b0ca96', 'Belarus, Minsk', 'LYAkuylxwzkRHI');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('4b1c152f-6a21-4c2d-a849-594dcc765758', 'Russia, Moscow', 'ftPAywSBuJMdbT');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('4d3f41c9-977e-484d-af5a-137c14ea51fc', 'Russia, Moscow', 'veYjLCKhFdBLmB');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('53bad5d1-efc4-4997-ad29-20136b443d1b', 'Belarus, Minsk', 'lmdGFOrnGgbXkB');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('64966722-d971-45f2-8ca9-86b729778f21', 'Russia, Moscow', 'XVGnmLFVsgeEKM');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('6b7b57a0-f2d1-4552-9fd7-5f08deb9fdf7', 'Belarus, Minsk', 'QnuwNBvtirVEPv');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('7a709432-5951-4ceb-a53c-5b5b50b29f22', 'Russia, Moscow', 'tufewvHzvHxsLB');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('868f8b3a-8663-47e1-b6da-1e19967980d1', 'Russia, Moscow', 'xAQHpAnmUAvUkL');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('87e1db06-970b-40b1-885e-c0e5846c2daa', 'Russia, Moscow', 'RGrQtgJcRjPQeH');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('8cb215e0-ec6f-4934-81c6-a3da964e67ab', 'Russia, Moscow', 'zUazJjVivcObOw');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('8ef554ce-204d-4a32-9184-2bb49204c27d', 'Belarus, Minsk', 'mnLaAtSaAOfjhT');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('98c23db0-00d3-497b-8892-53b74357c048', 'Russia, Moscow', 'njgYYgndeBfqGI');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('b2f64696-6a41-4bd8-9cfa-004fff92d747', 'Belarus, Minsk', 'naLtXoSHSkqOgF');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('b83b9461-d7ab-4c3d-a17f-d1d338daec4f', 'Russia, Moscow', 'haSKCZzUGtVFWj');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('bbb0e29c-a1f9-4213-ba74-02325dd1ebeb', 'Russia, Moscow', 'StvOythtIjVEXy');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('be754d29-73c8-4b34-9db6-951042f0b7f6', 'Russia, Moscow', 'ShDelfjIpbhcCP');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('bfec5b79-2b25-4147-b66d-75cbffa54602', 'Belarus, Minsk', 'MIYibPYCiQFgZC');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('c4b87838-3b88-4349-80c2-a1a3d4e85614', 'Belarus, Minsk', 'eHrwgybCRjFtNf');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('c4c40325-e585-4341-89b1-b121d36620f1', 'Russia, Moscow', 'wfIDAxEmMfMvzO');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('c63fd9ff-6a9e-48f2-a51e-a1f6a303a61b', 'Belarus, Minsk', 'oZkdbcEqFkUilE');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('c96d27be-a7fc-4970-93ad-d1a53cfd9ab4', 'Russia, Moscow', 'oEPlinqHaNjhDa');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('c9ac6729-48a7-4ae8-bdd3-cb17be918a7d', 'Belarus, Minsk', 'YvPwlHkoBYshWY');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('d71c5abb-13c9-45ca-ab22-902e601935a7', 'Russia, Moscow', 'uFYoFEasThZKFp');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('d7ab3ba0-9d08-4bc6-8d63-d5a6370e2464', 'Belarus, Minsk', 'fVWEcMPhJpkcHr');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('de965226-9a77-42fe-808e-5b1b3147cb14', 'Russia, Moscow', 'cSDlPYprnYHpUY');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('e0631d54-5572-4da4-afff-2f8a12cde795', 'Russia, Moscow', 'NRoqGZGpESMNKI');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('eecdeb28-5086-408f-b6a0-2ba60b155099', 'Belarus, Minsk', 'AkfysvsaGONjbz');
INSERT INTO "Institutions" ("InstitutionId", "Address", "Title")
VALUES ('f6b49c5b-2178-4808-98c8-8b629a93b2f0', 'Belarus, Minsk', 'iwhIpUliDDHQVT');

INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('05c314f5-89ec-4399-8e22-8758b261a788', 'Kazakh');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('3e72e330-b845-4eb0-84a2-c9072185bd9e', 'Spanish');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('4580a4ce-d0d7-490c-a084-522a3429fa3f', 'Belarusian');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('5f4c4bbc-5c03-4b9b-b54e-db0930717e1f', 'Uzbek');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('70ac3a7a-6a0a-47a9-b350-d7bb69058c45', 'Georgian');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('72ce4328-7613-4d9c-b606-378f0441c207', 'Portuguese');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('8650489d-76a1-482a-aa73-db1c61e85010', 'Tajik');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('8ab2784d-53fb-4f0c-be8d-ea0bce40ec61', 'Azerbaijani');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('9b3bac73-5c09-4adf-adfb-87f371b3cc3f', 'English');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('a2de0434-2f8f-4166-be19-3d76f5f83fd9', 'Italian');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('a463d76a-cbc1-4914-a0ce-dac72dbba114', 'Hungarian');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('a663abf7-d16c-4277-a996-9ff9415567a5', 'French');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('b60d1166-529b-4697-88bf-bd28fae6b742', 'Russian');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('bde87ad8-a036-4385-b44d-b78c5ebb4f85', 'Armenian');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('c2d2bbb9-4140-4ff1-979d-47da41e7d79b', 'Ukrainian');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('c429260b-9a74-4b3d-a803-6bea12f1dac6', 'Kyrgyz');
INSERT INTO "Languages" ("LanguageId", "Title")
VALUES ('ccad397e-ed67-4872-9b01-05666b29d1dd', 'German');

INSERT INTO "Roles" ("RoleId", "Title")
VALUES ('20c55b58-455b-4987-8aea-2f368d30a439', 'User');
INSERT INTO "Roles" ("RoleId", "Title")
VALUES ('7465fbc8-4249-4191-9747-3a52b6fe12f9', 'Manager');
INSERT INTO "Roles" ("RoleId", "Title")
VALUES ('78c327b2-118d-49de-a6f3-f17614a0f900', 'Admin');

INSERT INTO "Cities" ("CityId", "CountryId", "Title")
VALUES ('301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', 'Moscow');
INSERT INTO "Cities" ("CityId", "CountryId", "Title")
VALUES ('9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', 'Minsk');

INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('07491ae5-ae2b-45ad-90db-a548f5311fa2', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user18@example.com', 'aiwUmw', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'bfec5b79-2b25-4147-b66d-75cbffa54602', TRUE, TRUE, TRUE, TRUE, TRUE, 'wWamaTle', BYTEA E'\\x5282B37CE760A5FC9C68B798B44942A3AEA125ACE509910257B98D5AC9E9E4E0A124332BBD4BEA15CCCF8B1BACCB21C2CEFCB2FF13CEEE826D10C21C7CCF2195', '', BYTEA E'\\x71DBAD9935D2B8EFF760B2D6CA2A84C10ADCE299D12D2B122AA62C9674B8BE07AFEB33725B7387EEF1E8D4E9EEB4E7AD738D35691A170F5AB2AEE48E908C80D13B937FEB0D6BF461C71DD8C9AC831E4F53FADC4A4F8B73CA711B5A12524C2CB9AC6041256D880924BA3CBB0C54684B0FBDEDDACDDC4D94A6D2444FBCE8F0C6FE', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('2336ca2d-7566-43df-9d02-d0926279059c', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user34@example.com', 'yhDkJx', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'c4c40325-e585-4341-89b1-b121d36620f1', TRUE, FALSE, TRUE, TRUE, TRUE, 'kTiakqbp', BYTEA E'\\x6298A5E3F0A5D6DEF3A91C7C9C58C0F73EE34AF585C3A028A1D576E49D07CBFF35A44C6CCAF127F0C17800946D1750B3A8E676F878F8CF3E19E8BFB3A9FAEAEE', '', BYTEA E'\\x2DC1BE603B1090A069AB2580BE60BE717042DA723F6E100F4C8CABCADAF9CC36C0BA962DA6FBF30DDC4353E3464C8AFEF2ACFF702938A939FAF4B28B8DDC061F6F7CF17FBBCCA566EBB1C2964EBA20D714E6B7770F41F6902BC0695407CC8C0601310E26C344F367E559AD029CABB542D2D14E187772B1C35DDF46CE7AECD395', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('2d9d58ff-f7d7-40c1-9e39-9bbdb011cc1b', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user23@example.com', 'ZAxLGU', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'eecdeb28-5086-408f-b6a0-2ba60b155099', FALSE, TRUE, TRUE, TRUE, TRUE, 'Kkrbttjq', BYTEA E'\\x9FDF9657A3B200F1A23CB1934AEEED70C7202FB7264F1BD5C56D44263E65223E1DEE641D14C9A4CE4BA7EB170CDDE9995241A2586F2AD094ECF871989FC76BEA', '', BYTEA E'\\xE0B17CFDB17B6C6C1B62EFB03CAAD7FFA312F1627D31B040CDE15783C339694FFB6B0CB552EC5A7BFCDEFE7EEEBA94C07EAF6A1214A4D13B18A68EFE8FF74DAB7EB6937D741D1471709726BA519D0D9CCA712971AABFC2C355C6519FE6CC7BF4620B9C9B82BEE0934A61F772673A09A2FB0ECBDF20A6FFC2E3203B07DE38B40A', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('2eabce75-aa9c-40de-bf64-3d7a722d790c', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user30@example.com', 'vAmFcF', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '28211f94-f503-4249-b075-efd5712697c4', TRUE, FALSE, TRUE, TRUE, TRUE, 'mTYUVdnp', BYTEA E'\\x33412D24B1CC3C706BBBDAA827F077157A5E45C63F401BDE1BBCC27F40B796CA7984EBE2E13AA2AF04D713FEA770803331AEFC669217FFD88AFEBD0CE7B377ED', '', BYTEA E'\\xC82119AA0133223AFF1C56B772126ED0DA64B5A06CA4C05279A54B234E15FF92833D41DF09AA1D0610D10CFA48B2BDE69799A6365264D181EC187B6C3089699C437BC453BFCBDF61C75A4DDF563191E797249A06FFCE32F6333210426657A2F993D7A53086FC66664C9090C814FE68099066B3787C1876B06259C3EF0C5D6FFD', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('3a24b7ff-096b-44bc-80e2-a302ff25e895', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user13@example.com', 'PGFIbb', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '2f1cce1a-240d-44ee-861e-f94ef52c01a3', FALSE, TRUE, TRUE, TRUE, TRUE, 'EMlSwBaT', BYTEA E'\\x4508176C8C5A30DB3AD31C7C70DF756D0705D6034FB78CBF05FD8D9819676A1C023F39BC355BF0BB56283CDFC4EBD2EC23BA671A4C4A719BCA45F4AD1B125878', '', BYTEA E'\\xD23D1B8DC59134ED73C84E6CC99DBFDB90C72ACEFAC50C1821248B833647915B7741C79A3F1F9332404545C31BCBF3BD62E8E9C81A5F9019817567291D4963B0DE420E2D45DA4907FDC27C31D7BF2C7B933032C775F3CDC7C6EDECB93A353F10BD975F7CA4128CA567994C27C744E194168A644B2A33353A8850DF9582E8D289', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('3d39d3f4-94e6-426a-93e9-39eb65fc10e0', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user38@example.com', 'aJtlFS', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'f6b49c5b-2178-4808-98c8-8b629a93b2f0', TRUE, FALSE, TRUE, TRUE, TRUE, 'UjmxlnjK', BYTEA E'\\x2DA7E6AA388C7E94B692860B01A9E8285516B7D198CCB09ECE114A8C266CE44C03667AAEA818B99BCEBE56C0363822DDC4EA0922A7A12C8B9988CBF94D548560', '', BYTEA E'\\x4A94B64CDCC11FF1CADFE73B295A03EAF1BF95AE9AAF6930D233A03A2F546C9918BA63AC63879C74214C225071BD176AEA8AC8EC8E71A380A24788744A128686C72DA4E2EFA42C6263E52B39DD1B6219781FF6A53CE3AB3A40677474B3D1D72B1C3458B8F6456081F9187C39BDC3F4E7ABE35795E1ACE01ECFB89FA9458D3DD0', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('4c152dcf-9d6b-4a15-a109-ba38ecef0a4f', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user4@example.com', 'tKuHKv', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '215fe3af-f32f-46ed-adb5-8841653a9794', TRUE, FALSE, TRUE, TRUE, TRUE, 'GujVcvra', BYTEA E'\\xB09034CF1B924CA7FE97BA622D07E901B8E83467DBED44A315B83DEE0B248AF26EDD10894E188F97C0DCCE7F8E347153793871F095A0C6FF95D9EB78BB5A3296', '', BYTEA E'\\x53C2383555FAE5B688F65471167760DE6F509CB5240E8EA5F651F32BD18593C6F7139711FDA8A3AD9F106763F8C5B99A64EEAB508D26DB50FE1AFF57C3676147EF73FF129186168439578B6739EBC3EF517445C84B37D9CB66A4D0C21A5BECF178A3C1B7A862A0467F06D8E73FA74FFFC7448726E9D2A485384379389DB7458B', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('4f207041-33d9-4dab-a8ff-8d6a16c378c8', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user31@example.com', 'oymDBL', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '4b1c152f-6a21-4c2d-a849-594dcc765758', TRUE, FALSE, TRUE, TRUE, TRUE, 'dVJPVcOV', BYTEA E'\\xF5071982692F98F16A55089A35BC8D97759727F6962B6AEBB5FD8A4728469A833F94B5DC5C0215FE775855D5234D43F795CD492A42C3E8A55D1534604C1D55A8', '', BYTEA E'\\x73186013098EDB82449A92CC96DD20E9BF2BB61B2691B21D5F030E78C02EF32525D5127279BB0F1BA2A198602749D2B541761E2DBDDC69B03C2AB5E20AF92793D36ADF9DC628CD597AD8B707DF9FBC5AFA1AE52F981E82BA3D0EB0AF04F511551957A03AA12C51A279145E73F0C33F45589B99F74900DA1BD4B89FA39BBD791B', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('519bfc2e-78e8-49b0-a501-1261f211e260', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user27@example.com', 'xTcslm', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'b2f64696-6a41-4bd8-9cfa-004fff92d747', FALSE, TRUE, TRUE, TRUE, TRUE, 'sNtFJZUr', BYTEA E'\\x5017040F7AC56BA3DE67C05A8F03A8A64B207DDF3FF663E37E6D34AD2583DDFCE3C50FB663D2AD800F6F8C84C2D2CE2F50547B6B998124724C05DB184226C75E', '', BYTEA E'\\x395BF7C5F3793C477DA77646FEF81BF944F6CA346594523A3E2C7904BC1BC4A256C484150FB9A6BD5DF5084D2BC6219A5F6B1AE02B1709156899EE7E6FE72D19056DA465D1F7CACAB329413A99BDC1F10B6DEA42F169D32662A041CA70551282575FA69C18A190F73CF2216B6D24CE370DE20B78FA6234D1C1BE41264FA81E8B', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('53645d80-1a98-421a-b4eb-998283f44c76', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user6@example.com', 'zTvmXg', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '868f8b3a-8663-47e1-b6da-1e19967980d1', TRUE, FALSE, TRUE, TRUE, TRUE, 'UJrqQuEx', BYTEA E'\\xD13F08F4C4999A93AFC5789162DFD312DF4F5FD9D93C73424175675EAE7E63184DF17D496889ACD8D02953317664FBD1BD271013CB542C70FF7AFC4D8C132FF0', '', BYTEA E'\\xB2100F578BA808972E95CD2B49B9AB86C9947D6EDE3AC4889CA010F81F45E1B9CD99F6118E27540922D203E1FCC479CAB517C887957009126386152A7BE6CBD40A3FC79BD92408141915A420B9E9DFECDDD05E5C85D2DF1286B236D46F973D5207C50EA285132F867EE63B11B54D8676DA75DE07D57622F0724DD733EF7170D3', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('54ff243f-4c44-4b60-91b9-cb6be6a1a59d', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user36@example.com', 'VhMhHo', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'd71c5abb-13c9-45ca-ab22-902e601935a7', TRUE, TRUE, TRUE, TRUE, TRUE, 'YXWVcrxN', BYTEA E'\\xE75988E35DD4FD25BE74D16C043B672391CAD836414F5F35B27FFF0D560AED2777A780B9D3091E5C5CE9D73498EECD996015E86DFF1447259BA78AF9617122E1', '', BYTEA E'\\x986527EBA9520733C05116257E2E65A853BE4705A839277074D6C370A93F52771E9DD891011427D75947CB393701DF0071D6418350235DEF18C8A77EA694A1BC3D773AB3DEB58C28708F11EABA3AF67F3AD04E0F7E944ACDAD564010225C98D20261E000D043313FE00A741054A70C164BE4D8F8AAEA84B0990130E84156B691', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('5f2a6b94-28f2-4036-84d1-6655ad754538', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user32@example.com', 'zWioog', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '17d0068c-37d1-4def-8ef9-e55a1f5a780e', TRUE, FALSE, TRUE, TRUE, TRUE, 'aWdOIeCG', BYTEA E'\\x5A736696770799534A52D67B9F6F40FCC154B227892D1681F903787EA56546A279F98071AB84C85DB5EF1DC856DC1ECA274EBD4AE6405A30DF3F61423E7664C1', '', BYTEA E'\\xE573F5D5E073BD672E2B79302084A158D1E077D23EF2FE617930C98D1263DF5CF51075032DA6E574C3ECD78FC181E6B3BA7022796CCED2C1ED567FEBE1795194494B5F3FB9F4B76A039AF92A01D9EC088F7ED98CCC05BE1D408E863B70108ECCCF624AE835F93591302C7EFDBFBC84F6767709A6FD6D553E9A42696EE1458305', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('66f425b9-cc91-4d7c-bff5-b84a49a32331', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user28@example.com', 'gLjfOL', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '53bad5d1-efc4-4997-ad29-20136b443d1b', FALSE, TRUE, TRUE, TRUE, TRUE, 'HwcIbFkn', BYTEA E'\\x60D45E1FF0024F4D939BCA2CBB5218FDCD08670FE77F9E2F05ABC77131258C244C79AF3EC333FA47DC9B570E843492E8F5181D9732B3DA067CBB874C5BB245F2', '', BYTEA E'\\xD8042B3B7249D2C48A8E027BD38BB3195F6CC4BAE782621B90A30C7D2434B1343053E1989384AEAB85D895DC49308F07C01ECD917E1CF5D8962430357934ED7C045CFB94B462C0A5F2167BF676887CA9808B24700E355C669E9F438991CCF0C5967E773D865A1532AE97D6DE6C66771312546C2D72488AD93279B160A4EFF0E4', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('69747c3f-374a-40aa-8c5c-abc1e59c6ab8', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user12@example.com', 'RfmBZJ', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '98c23db0-00d3-497b-8892-53b74357c048', TRUE, TRUE, TRUE, TRUE, TRUE, 'PXcvYrdp', BYTEA E'\\xD9360CD17FB7B575DD667F6807924FF4A6FF38C197487EA7990D9975055DA59661F8B4E6F8EE084A59BF12052D53C05CB301688CE78EB1262A8C6DB09399D95E', '', BYTEA E'\\x00CB2EF4F5CCA8A34D8865702C2E5F45061533D0E150CF8CCCD4EF8A5E232FE668B3873BCF3A18AC2EAE2D5A35900DB407FBBD827BD86EECB63FD2958B0D08A0E96D90B9E53E231D16638D90A7690DED2A2F4B74B6628309969540EB547FC8B64645FA415B2053F785364CC42E4F9712A16928850F82460A54C2F381AB31800C', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('77dc9df5-b30b-4f3a-8ce5-0ee4f7393766', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user16@example.com', 'nfkpUG', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'c96d27be-a7fc-4970-93ad-d1a53cfd9ab4', TRUE, FALSE, TRUE, TRUE, TRUE, 'ucdgUFBU', BYTEA E'\\x60313E3A6151DC2B80A7DDDF998871D915FD3055335F0D3AD6A099607AC004D22DD867477E74EBA5F06F90987DFD58B3B549B29DB50DD8831546BA334A872D02', '', BYTEA E'\\x6E05A0CC9A13C206C8EAC0496772F463D88E05B6F490790774A8768C6BAC392A88C199980BEB64BF75BBAC66D16867A0C9530264B1B80933167127366ABFEC07E857543C3E259BF7E7A7AB8AE55507F2F88DFC5C1B7D7DF2A1962E1F57B03E5A8E736DAA83429795DE5D3382DAB9283A93AD8FF77972998DD4C9F6B9F9261FE7', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('7b8196ba-ba49-4c9f-9c3b-620dd888693f', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user14@example.com', 'PYdTyH', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'bbb0e29c-a1f9-4213-ba74-02325dd1ebeb', TRUE, FALSE, TRUE, TRUE, TRUE, 'zKNuVoiD', BYTEA E'\\xBA4237E63C210A8BA9A0EA930AB7E8F58A87786B04617096248AD104A7F48F12F1B34ACCAE0128874722D20B29E5D87E0A11C93ED0CBD077FCDF41EF5D17EB27', '', BYTEA E'\\xB4C678AC0857E8AEB4DA12B7969A9C51E56F6E3A79DA93DD616ECB876A96072DF10933A116499D29B7F70345F6528EDB5A466B4BDF49C3FFA20132A97D92EEF4D68E6DE53A79C21C2BD0E4793A30B569BBC314E31EE7DA158144839E67C06AB2BA83E39138EE9AAB884B235E5DE4DD4D3EA4FABDE49D699A9EB2B3ABD0323820', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('7ea4e7a9-8e85-47de-8082-ba2c393d4bbd', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user9@example.com', 'VNNHTW', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '7a709432-5951-4ceb-a53c-5b5b50b29f22', TRUE, FALSE, TRUE, TRUE, TRUE, 'MiDWNafi', BYTEA E'\\x7D94B1689C98A8B8E7A5140959FBAAF7F06C2D1DDA48130EADFDEFDE632E838BD8B83E9E167804A6F4ABA2BE8052DBF1F297232961F0BC1FA324A89CF03D251E', '', BYTEA E'\\x6A1580201A58E5EED90FE896156C5D6FE55DFE29F92BB9C31EF6D489186F109E3E2A0E116CCB9FEFD0CC99ECAB5B2E6D4EE79278D18454610919BDAC2540834982F742057D634D8B709754B9C582B4B4C2D2310F53A3BB63FB45D2372E529BC29CC5CA903BE675ABA8DA0F78446C679D1D375D2C1048BCA7CB8CEB1D3FD12D9D', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('88dcb8ea-e774-4bd4-82ab-9870ee8b4680', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user29@example.com', 'AbXQxT', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '3bc911ff-aedb-41b4-8981-1746e0e76627', TRUE, FALSE, TRUE, TRUE, TRUE, 'RkCTkXgI', BYTEA E'\\xE3B83ADBBA6569F85C9FBD64875F156C403DD36BDD61420D68DEF286AD1EBEE815392D7730AA9F0E0C3ACE08C6291FA3D331285B321089D1C1E4E01F5FBE3E3C', '', BYTEA E'\\xCA714E9BF0FEE3DC149AD79AF659BE971DB1A127D1CA5940C89B930885A59471A4FA70058FC1956AC7EB6CBF90016137DB33C972ED03EAD611D3AD2CD0119AD4A81F19DCE0B37B97BE8C0B56F5846D3DF97A226D059FDF45025CF760D9023E505A93346A27DF752902D03370CA758559207338DEC190A2657E57C34FD5362EA0', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('8deca522-cde1-4712-9ec3-0079d21b69cd', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user19@example.com', 'UbausN', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '3a046f78-4ba5-437e-b538-8add4522d6c1', TRUE, FALSE, TRUE, TRUE, TRUE, 'CISTTeEH', BYTEA E'\\x694CA46E456A40662B5B928ADDF41DE90206FE63FEB4B371F983B38FD8B686C7D51D0D9EE3FE0099CEF985BB91B1E80927B3E5F35C8BEFDB0344A4450EEF26D3', '', BYTEA E'\\xC67C513051B376CA700A19B8FF15D1A0D6844CCD8185E8A247DAB25D9DEA2AAB20EFA99EC82947FE097BCB8651A52B67EF4A79E4743BE791B5D4B32039C668EBD12B6BD468C280EEB61C030B075327A8702294103A0EDE348702A16736705E0F3B62F4B671FE72DAED447944C38950656AA589E6511918A39E26A90ADD186694', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('93a39fec-228b-4114-9dd6-5e036fcf0903', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user21@example.com', 'BIaepN', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '87e1db06-970b-40b1-885e-c0e5846c2daa', TRUE, FALSE, TRUE, TRUE, TRUE, 'uneRELMX', BYTEA E'\\xFBF0D2887E0B46203A2EA1EBC815D325FD9EC63A6F65756B35E270EB8F3D163B9BED54C445867EBFCC5529FA4E3B24922A0101B1BBAFD4FB58970F179DFED3C9', '', BYTEA E'\\xA35ABCBD268D62E617717E83A5715425FFD3941477237C572769C3431817D549979181F9AF67423AC58183A659D6DE2D20AE57D83A11E2B16A1486BA661F285AEDF36167AC5A84E59A7638715C692BE12C9C8F38A1B8DE8B76C3D9AAB9536A8A92E88BAEAE56521ABF264478C885462546C8FF0875C7635E0DD20B95D3F2D411', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('a64f5b1f-dd98-40a2-9246-0e49b8af93ab', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user8@example.com', 'HiiQKe', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'b83b9461-d7ab-4c3d-a17f-d1d338daec4f', TRUE, FALSE, TRUE, TRUE, TRUE, 'uYrbiqWG', BYTEA E'\\xF85ADE34FECE6B46B88394294E42F7462447DA769316149AB4971AF5C8EBBE9B44D905D1856857693DC1048D6ACB35A6752E7D33325AACF558EAF0D2725BDA52', '', BYTEA E'\\xDE5C27E145DA5D2ECCD86AA5389DC431EFD1A0E8C07C2A78A2C871456F37F19C3087A508F79E1C2928CD44874E440E36961370BA7B4608A4CCD5F72F2A6514E3C5119FCBA12DFD344E868E34A335EE79954EB302EAB13880790B9C1A32AA52DC8894040D9794887E45E2DA0BF4591A7B44C737A2C09834190648F86714B2A937', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('af3c30f1-1864-4214-a470-3a6384a68d0e', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user25@example.com', 'LQUJxM', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '2078ec21-1fe6-46fc-91c9-c50b24811b9f', FALSE, TRUE, TRUE, TRUE, TRUE, 'fUczDCis', BYTEA E'\\xF30BFE949419E53A8419B9C88FDBE59779E67D825D7C9D0909B6293D50B83AC979C866F04B0C92B37712E0F0F1E107EF0B7B9FF38F340428C547883A32FA8EB8', '', BYTEA E'\\x6452DA6B297BDE025C3DDBB7EFB544B8868DE17C01BA102A899A99370CA916E8C41CA2CF6126E8193AFEF690420C06AA6FB742661C1E308C2DCB1DDD8630C54D2DBD135E1BE1A8A9497658C1D5C27796984C61E0ACAE13848BBE59C450DB85F9B388CFF1D5B8C6136BB04AE4C989A1C7B5E4681FE213AED3EC7FE8F6B9982DCD', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('b0fb5d0f-2c35-429b-90b7-2b21b4994118', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user40@example.com', 'SkzrMy', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'c63fd9ff-6a9e-48f2-a51e-a1f6a303a61b', TRUE, FALSE, TRUE, TRUE, TRUE, 'sMgfuwwc', BYTEA E'\\x6C93B27FFA263F2BCA478FB9E595A4D5AB56C95A9BB526F768FC1CDF213382DBF577ABB301DD21AF36992A663002234F72351AADBFC61882E7DF2AC6B89ACEB5', '', BYTEA E'\\x68EB2010A9DC0B71CCE3EB7F3E565E6D8BA1A6D9ABD6C7FBAA94C7E4B28A8BC6FBAE746331D6D6F8E7C90B7381C55D308964ADAFFBE04066352CBDEBE0F5AD7217F18B3AB8D444FAD18F1CAA07BC1D04D24FA8465B8F8059ABBFDFA2C39B712455E4F3E602C48328BBF2B47850E3954114091D8A4CA8090804F1BF0FDB3CF2E9', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('b346e7d2-2ea0-4785-82b2-0835c4ec1388', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user5@example.com', 'MEWvEA', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '41fa205f-8b50-4a04-bece-4e83d770d4f0', TRUE, FALSE, TRUE, TRUE, TRUE, 'guUaLSZQ', BYTEA E'\\x672330A4DCC477BE8379B21AFE1A868952DD8EFEA732A7FEF354100BD75F960B042C098E99959980018748C7549FDED4B94525826B639B85672F4C78DC199894', '', BYTEA E'\\x57BE2473D18DA0F1F8C21E2C697DB586A77D78626D36D6BD3E0FE549DD8810620047A2072F1C6DD6E56218F26303C5A2A1CD91EB72783A3882515D4049169155054CCA9B905D1DC480EB09EF62F7D24526A63D293F914E9139DBED7377A614DF0BE49F4278E480AD5A7F51747FB932A018038103AF2F763624F04B3B5F2891C8', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('b6209f1c-aaa1-405b-8c1b-b761c2f8343e', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user26@example.com', 'FIkLQK', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '8ef554ce-204d-4a32-9184-2bb49204c27d', TRUE, FALSE, TRUE, TRUE, TRUE, 'HHhfjtXe', BYTEA E'\\x4C56942B85513E694051E2C70EF0EDB141161AA747095440776E2DD1EEB60941D31E6C9707A881D3D24446BDF72C2C4439AC2EA846E6530E3BE5EB1072B87C41', '', BYTEA E'\\x47DD421332DE8281DE63F3A1B2B0EB04E105142887AE7BFAA0B56E8AA4F36ABF9D703E074D6ECFC4910CBCC96A754A92A7DE8FF77EE62D2FC5F9F59FB97E003BBF73B8DE3689CA52F5E3CCCA66CD9AD9B1805025742599B2EC22FFACD1A91978791663C9A4B17530CCB3C2ECC13F5C7E71A25C08C4A93B939828C2F61E496C0F', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('bde98c77-f917-453c-8455-d8529c72b945', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user20@example.com', 'YGMtCt', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'de965226-9a77-42fe-808e-5b1b3147cb14', TRUE, FALSE, TRUE, TRUE, TRUE, 'NReEQXoW', BYTEA E'\\x403377EE55AF46A61855495397DA3A53EE8854C218F624568F2BCF3D8DA839C262300FF3203643435CA96976EA893328A34B7130D174CEDD7283863619D54BF5', '', BYTEA E'\\x065C6DD915A8AEEBB54A22DC6A52F36C3C639EDEFEFE5EFB306BFEAA50B5D3B9D351F7A614FAF8BE24083A2C20A7AF6724E351B0E710AD48A8770F0DD162089E5DE4D599DF65FD6D9C1FDE361CCDB9263441533D692E68BD31187875AC0AC7092DB0B96079C2169DC3D9B2AF45DCB808CDD0701093F6D47B25094155CDD05DD9', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('beca035a-6bef-41c1-93e5-ae43872c0c8f', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user24@example.com', 'aFUEdN', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '64966722-d971-45f2-8ca9-86b729778f21', FALSE, TRUE, TRUE, TRUE, TRUE, 'dPFnnpoK', BYTEA E'\\xB352BE559E929E0C1160F5783085670B8FD3343B1507535A102A723BA09B33CDDD9B145900C4DE025E0FE272340EB155939657A28E1013959CD09FE48D06621C', '', BYTEA E'\\xD4E06A8473E1F8D3C543B747111A5CEF9799B422088C3288517C28EF2D598E5222D8AE8A44A68C0325D1CDFCB325020F235EF22146C5AC463E30AD89DF1893E9F7C15324DC1756EA5FAFBB847F0E165FDD1A6423EA270D33175199E76A233EC079C4021ED50004A2109A258BD140E5577CB6504440F4AED2DA1ADD7DA6722E01', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('c5864a88-eef3-4f32-b816-79fc02b37a28', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user37@example.com', 'xmcXPn', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '2617d600-be07-410e-967a-5e4f94603089', TRUE, FALSE, TRUE, TRUE, TRUE, 'RdFyLDIP', BYTEA E'\\xDD3CEA851DCEEE60EBFDC1D325DE7687C3DED5172E2336E501E81AF3CDC6529E8D923ABF3ED2F2DBC1BEAA21DD5576407F51A0155215652E2DB854E41FBF5EC8', '', BYTEA E'\\xB8B357B0D47B9BB01121C06A981368BF05AF2DAC378DC6E8DA88A5F2F06B772672592832F351FC57C9BCD31611F818F936008FE4F58FA74010A61653D11C6FDB33F4E5EC721E09E901C457837EC9C2634A8E9A380A28BA625D58360ED32D4D7BC54B12279008B02F30A87144560A7A11251CA0E3581DA58A851E9CB3F53FFAFD', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('c781adf0-0f88-42db-9131-7a7a1c6712bf', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user2@example.com', 'CKacOn', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '4d3f41c9-977e-484d-af5a-137c14ea51fc', TRUE, FALSE, TRUE, TRUE, TRUE, 'rfewFUQQ', BYTEA E'\\xE4AC9A3EC9D4369208C50C44118FA5611DECADDA90BA54FC9B2D7385720B319564A19C219C8EE4B644D3785934923FD0392840342D870B4B33987A33C788A47D', '', BYTEA E'\\x96E5583C34F93DB59143F8B4E741C45D14E6C89782D41C2498C57CC783C7B38475A95D017B72A6D9163C6832D9D70B4A71F09068CE6C541468B142447486967425A9E32D92E9DD92025E3D1C5F717608E9EB3FADFEF9D0A783011EF2282D90E1E46D58C208F6CCE857D647DE6999FA06E45116A45BB6C00FA3306836359EE8A5', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('c7c7ab42-1fab-4bbd-b409-c4b09ba2f540', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user7@example.com', 'uENhpR', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'd7ab3ba0-9d08-4bc6-8d63-d5a6370e2464', FALSE, TRUE, TRUE, TRUE, TRUE, 'rsHzfgXt', BYTEA E'\\xCC2DBED2F88C986E53B0DDEB45B49BBEBDA41167A5721066D43C11233C92B3F65DDCCE7796A031ACA5959E4B2CEFA65DF9B4324557FE615C961F8E4F04A3F955', '', BYTEA E'\\x6B2D1701BEAEA50833AC5240084DA005C9ECC7D95FB3B380EA6C7C1DF0706EE0BCCCE342F5A77611D92079AB5DA44DF0057595D080947EC16D836E4BCB90498BE5C76C477121EA56C7B90721B5D756E35A89EFF436DA52D18D616ECA60803C04B6DDC06E36F1256D230BBCC181F32845F05CB1A9E97207F9DC51DC71AB684E0B', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('c8d9c72d-f99a-41c9-ba35-195684f8f9be', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user1@example.com', 'BDJFdd', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'c4b87838-3b88-4349-80c2-a1a3d4e85614', TRUE, FALSE, TRUE, TRUE, TRUE, 'vUDTteVx', BYTEA E'\\xC2CBC6C3FDB8579E4277489BF19BFDAAE52005288E90718AE95FDF28AE028A64E1B7A03D9C6D1BF0D93F15BDCD4994BDEDA59AC61E3B1D069488D7BB2B558785', '', BYTEA E'\\xBC3C9B2FED013CE8BD0ECB2F3C14AD766EB3E4D6729359E8517F1BF8F9683946E2E1DF36F81C82A73BAEF24C81AA16F636F618FE312942C908CCC6782B1D478F4B925D38E21BA7DDC41FA50CB07DC4F5542F9C8B46E13AE4659C8D784EB4CBBAE6E9E2F5B7BB2F80E24D8AC5347E4593A0B91B36BF8BF6E45C87A1E5848309B7', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('cd0e6a13-f0f3-47dd-b1b3-022d429be1dc', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user15@example.com', 'zUDakD', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'be754d29-73c8-4b34-9db6-951042f0b7f6', FALSE, TRUE, TRUE, TRUE, TRUE, 'ZbOVcVlk', BYTEA E'\\x0C5BC05DA02E5A34E225497D48A7329AD3C47780299298860C4CF2ED4C4F0603336D0F7CC8A8450A371674CD97950053CB59DCF9A71A7CB67DAADC052BF54678', '', BYTEA E'\\xCF01621C5DB5F08CD7A0B232F313D07A6DF4E02F254B8757CB1C97CBECAEACF699099B9FDEBC6D20C9D67177285BF175918E7076C4BDB14FF82760EF5185A962CE8EB3C21F1F92E6AF1AB61474CF50CF60C833CA19426BDE2F10048B88FE09FEDEE18FF4524A842572685ED067FAF5A9F88CA500CD24C6FEDEB3D73C57206CBE', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('d6f385e3-fbcd-4c07-abf4-71d541ff2858', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user33@example.com', 'reaFoB', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '6b7b57a0-f2d1-4552-9fd7-5f08deb9fdf7', TRUE, FALSE, TRUE, TRUE, TRUE, 'cPHqdDTa', BYTEA E'\\x4577ED02B3B563EBFFB1CE5DE059120B3620F7EF3878BE919824D910534CA5BD1438BD7DB3913CDFB0816D88823E680493A2561571431187FAAAA9942A7981BE', '', BYTEA E'\\x6397917E879557908E8EADF19EF0B1619DF443468EC66E523346F0A3D285317ED564A8AD67700A32F1C0CEEDC5C827BB4E5A7C407D3FA28F1D3733E2E86AF0D231C98BA64DC1F3EEEAA780064AD02B33B2198E49D9FECB6B6360DB2366C19F4CF012642C1023EA0F9F15CFBCE168F7832E761D0728493BCB1ED5C454A07E2727', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('db31846a-08a0-4745-baab-8ec8404a9c6b', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user10@example.com', 'ftbBdi', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '0333432f-526e-47bd-b204-9c0bf9a1d828', TRUE, FALSE, TRUE, TRUE, TRUE, 'ReZOlYrC', BYTEA E'\\x7D59365CE3574DF8006BB44A68FDC041118FCAD97A74A2B341BF6BC82754B10A073BAE8EEC6784A0AE770CFC14E58412B965B1DDBF6F07621FC2599F5C7F6423', '', BYTEA E'\\x3EB39022340FC773530A752C7D993286924662A95FE2383123D3836AF6F156EBE111F86AA516CB53227A9247A02920189162F0B4076BB457E95D9B39304ED57FEDF9C84EC2B4B709ABD711D43777BE5E31816072D48BE9F2189987CE7FAC35A99690844B15129F58C06512E83BC7629FA9D86E7E219B9DB507309A6FC0F7492E', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('dbc4cd6c-406a-4e1b-9355-e7bb2bdb51cd', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user11@example.com', 'hNWsYH', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'e0631d54-5572-4da4-afff-2f8a12cde795', TRUE, FALSE, TRUE, TRUE, TRUE, 'yzHgKNfi', BYTEA E'\\xD0B595D380FA9F81CEF4B70355C09B5A83726DCFFF62E69DDE05C0987ECCDD75A021C87C12907A0189F1F344A60D8BFC92BEA1DA0BB174CDEE691084C6A2BA94', '', BYTEA E'\\xB23288A8CAB42CA3A33ECB1BBC9AD644091F49039CB33613546CBEFD7460C36DB522050000F319B6CC5AD280386B24605E679D14352BA4D64D1B572EE20AA409F669C2A2BFBA55644E321717356B1472D9C1CED670CD7CAC2F554C303FF9001AD3D127CA3891972BDEDB59D3ABD7B08EADD8CAF4A5E7D4FAFB0F3962C7DA1A59', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('e202448d-ade7-45c6-904e-862121f51b62', '', '301b2ec8-6fdd-4180-80ce-589a3d9d4e5e', '7feac47d-5c1c-454d-b2ef-c60c6c75ceab', NULL, '', 'user39@example.com', 'xrYsdo', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '8cb215e0-ec6f-4934-81c6-a3da964e67ab', TRUE, TRUE, TRUE, TRUE, TRUE, 'WahcmvpF', BYTEA E'\\xB08952F6328473E7AB9F42BB44E1B04F5722604B9F456DBD2A678FBB8DCFCF5B2F14E2B1ED00607E100832F2E0A49A21FF34E89409B69D44DE5B0072FAD1A8BA', '', BYTEA E'\\xE00E6E1F39989689E15141FD0F731844CE213CD4BB9CC3EFAC43B33D22C2D5081AFDAAC344A705F9CF8DD0B6E2E4CF8BAF733F14C1DB4C94D5399477A959C671ACBAB419FE4C8DA5EF1B294E9069009289FE516117CAFEBB63D7F0544CA82F324153B6976E535B74871390C4FC327345D6268428C54DBFFBAEC4254DA398952B', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('e98be11e-ff44-4e05-a1a9-c5c4df7e1fbf', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user22@example.com', 'VJjdgG', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', 'c9ac6729-48a7-4ae8-bdd3-cb17be918a7d', TRUE, FALSE, TRUE, TRUE, TRUE, 'HiTZeBdz', BYTEA E'\\x8CC6A727610316E4671E8C3DF6A91CEEB3FCD81C0592E08727DC16841F72DEE24015686CD8695B3457B56AC86B4E2449554D6F456E3D416CED9F9C587AF8D6D8', '', BYTEA E'\\x66B0A6BE2E4E908FB2F8C1BD0D2AA2C738A5FF2D2C1674EDD34221DF8A3712DCEE06FFB9667A575E9001B9AFD17147D7B5F90A902B7EA48C25B19EC4AF5A13006FD1439647A02ADC0F282871741AEFB09510FCBFBF40274B6ECD324E48D1A90B5294A6C853DB36C19386D5B3949649BBAF83E5BE026B35E9DE3A52B36F87F441', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('eb159b1d-72e7-4fa4-99bd-02190ac52469', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user17@example.com', 'xkboMP', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '0ac9bbed-525a-43e0-bf61-ce6bf4df3cc0', TRUE, FALSE, TRUE, TRUE, TRUE, 'KqmFNfKR', BYTEA E'\\x6A654ACA189D7A93F8F8185E015455487E9A0BF7C4FFD76C5882DD09A6860266E255912FBC9BB63AAA8D8621B8A37660C7FAFFBF17435DCC69499302EC968248', '', BYTEA E'\\x791A2F6F081C926B69DF41F39AFD9DCFAC0B363B234007D560A3D40A73E3A0178A31C4539A1F0529D834D4CA6C2544BBF665FB75270C6A5202AF8449C9014361699D2AFB9CAC30C3AA34811E2804D704523BC558B47A1AAB6923B5B359197B2B3B6FF9AE2F7A35EC1F917B9869BE11F07ED1D0DC446B0DD877D7D097B2E63A88', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('f13c8138-1432-4cd0-8646-7e32a8098dc1', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user3@example.com', 'RMKXUG', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '45c00ee1-dd5e-458a-b2d9-cb12c1b0ca96', TRUE, FALSE, TRUE, TRUE, TRUE, 'MtTqAKSc', BYTEA E'\\xCF906FC4EDDFBF2726E0C348FD4C93F4FA6254BE65B386EAF370CF6CFFD383A23A798995AE93938776528C7D03BCFF33E50BC6DBB58D0CB767F1E90D0835D068', '', BYTEA E'\\xAF88CED5F7101A3DD315106C14BBF846478AE5AAC5FBE95F3CDBB21BF02DA38BDD96CCF2A8A1A1B563B37CB4769E3BEFAF7656EFFF56E457C95E447F5B1F7659584B4931637F002C0837B55CF86EDB46E4AAC2F23EA64845BEAB2765F0FC31B4355FCE1FDC06BDA8C9894D2E8F0534338DE6146251C872ECA3F05EF9F47FD128', '', NULL);
INSERT INTO "Users" ("UserId", "BannerImageUrl", "CityId", "CountryId", "DeletedAt", "Description", "Email", "FirstName", "ImageUrl", "InstitutionId", "IsATeacher", "IsAnExpert", "IsCreatedAccount", "IsPasswordSet", "IsVerified", "LastName", "PasswordHash", "PasswordResetCode", "PasswordSalt", "VerificationCode", "VerifiedAt")
VALUES ('f7882287-6b00-4c5e-b8cb-6e4fe57c460c', '', '9375d695-968a-4d10-aa75-0c911a2e05db', '14d8a226-6f56-4193-a654-0db8d58ed38a', NULL, '', 'user35@example.com', 'ellOty', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/Female-Teacher.png', '02c391a4-0fd2-4642-bb90-f1cbb272a16d', TRUE, FALSE, TRUE, TRUE, TRUE, 'zhvKwLcg', BYTEA E'\\xE9AA11FDD6E5478B2CC0419138A273883D88F5C121ADCD9CBB5A58BF41EC8E9266C9F4CEDFC3666062102C6BEC126867C1FE0094E08E2191FFD65C2FDD946F20', '', BYTEA E'\\x5A99573B0FAC468AF0B1F9A480C885E773DDB69DD83CDC1B04BF579FCD863CFDDAABBB7D7E2CCE7B541AF16F33643028A00F04A11FB9C08A3A5F04F99346E34942E6FBF0566D39E9B0B7F02B70FFC75858B6B96657E5C2D77DB63D1982BB8CBD7ACED1D38950B33609B6C432ABFDB016442D3203B7C309E10291BF45CABF1BEF', '', NULL);

INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('0e70ed51-320f-4819-9c80-d1e9dd78b7e6', 'ff71d771-57a7-437a-a6ad-d81b7df8849c', '91b147da-00e6-403f-9656-3c1ce0ea1f7b', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of BIaepN', '93a39fec-228b-4114-9dd6-5e036fcf0903');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('0ff3ced7-8fe4-4ca8-acd1-234bb112f6fb', 'd9f732c2-370f-4536-8385-e9028ceb0f00', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of VNNHTW', '7ea4e7a9-8e85-47de-8082-ba2c393d4bbd');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('112ed03c-8e96-494c-8df1-f371684da2da', '78bd3361-7a78-4dcc-98e9-9c5071facfee', '8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of YGMtCt', 'bde98c77-f917-453c-8455-d8529c72b945');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('121e8327-68ae-4de5-80a5-602c9f3088bd', 'f243d0b6-9462-4190-ba6d-b2b54433d512', 'ada13721-da9a-48ef-bb10-99c2ac3ab1a5', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of UbausN', '8deca522-cde1-4712-9ec3-0079d21b69cd');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('170ff2c1-5fb1-488a-8901-a991babb6263', '295166c1-e0fc-405e-ab7f-ce8ccfb98f9f', '8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of vAmFcF', '2eabce75-aa9c-40de-bf64-3d7a722d790c');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('1c65a2b6-42a3-4429-8fc3-baa3fe101be0', '015fa99f-240f-417c-be8e-d7c439121174', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of PYdTyH', '7b8196ba-ba49-4c9f-9c3b-620dd888693f');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('1d01e0ab-eeb5-430f-a6ea-bd6584d92ea8', '17804eaa-5545-43ff-999a-322b3eeae281', 'a96f0ada-2a48-4792-a13f-0875c17a54ba', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of zTvmXg', '53645d80-1a98-421a-b4eb-998283f44c76');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('1e03add8-94e0-48ac-9b39-d8064afe7f74', '2885cc04-9a6d-4e27-b195-873fb9ed6006', 'ada13721-da9a-48ef-bb10-99c2ac3ab1a5', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of zUDakD', 'cd0e6a13-f0f3-47dd-b1b3-022d429be1dc');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('2f74db29-ede9-47f4-9e65-46fcabecf427', '5533de6f-51dc-4c9b-b38e-5f10f03ad259', '1253bf02-ead4-4b35-932e-e8bd142c6787', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of xkboMP', 'eb159b1d-72e7-4fa4-99bd-02190ac52469');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('3389e490-c298-4c88-a99d-20816e644fcb', '5533de6f-51dc-4c9b-b38e-5f10f03ad259', '91b147da-00e6-403f-9656-3c1ce0ea1f7b', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of SkzrMy', 'b0fb5d0f-2c35-429b-90b7-2b21b4994118');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('3ea7f580-e018-45da-9647-44f4958237ce', '89e95ed1-8088-4340-ab37-1386de70fdd8', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of nfkpUG', '77dc9df5-b30b-4f3a-8ce5-0ee4f7393766');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('44652512-35dc-4433-801f-ccb53458815d', '9e12b5c1-2aa5-4568-940e-db882e03e2e5', 'ada13721-da9a-48ef-bb10-99c2ac3ab1a5', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of HiiQKe', 'a64f5b1f-dd98-40a2-9246-0e49b8af93ab');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('4a3b8658-0b18-4525-819b-9c1fc2ce6cfc', 'ff71d771-57a7-437a-a6ad-d81b7df8849c', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of ellOty', 'f7882287-6b00-4c5e-b8cb-6e4fe57c460c');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('53a09989-e812-406a-9697-a43340cc2c35', '89e95ed1-8088-4340-ab37-1386de70fdd8', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of aJtlFS', '3d39d3f4-94e6-426a-93e9-39eb65fc10e0');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('61822433-c9f9-480a-823a-9b927c288e28', 'e3fc8b5a-bc11-4ab4-bb40-d7503d7de16a', '791daf36-d1c5-4453-9bfe-2f509894f43f', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of xTcslm', '519bfc2e-78e8-49b0-a501-1261f211e260');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('6d982b18-9790-4d6d-b15a-9bd71a6f68cb', '2885cc04-9a6d-4e27-b195-873fb9ed6006', 'd61fd4f1-352a-4e7f-a0c2-5d7ada20570e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of CKacOn', 'c781adf0-0f88-42db-9131-7a7a1c6712bf');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('78b86af4-a3e3-4749-b9e3-53ea68015ada', '4c616c7f-ab5d-4813-a751-3b2a18470971', '3bf4b91d-cf09-4b4d-8f2f-1e967f36ef23', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of hNWsYH', 'dbc4cd6c-406a-4e1b-9355-e7bb2bdb51cd');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('7fae7fd3-2506-4bc6-abef-76c0bb24cffc', '1752f8ea-2cc0-4068-8a2c-d4a1e640503f', '791daf36-d1c5-4453-9bfe-2f509894f43f', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of RfmBZJ', '69747c3f-374a-40aa-8c5c-abc1e59c6ab8');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('8d028061-4694-4e6d-bbd3-4fa9f4d3d391', '17804eaa-5545-43ff-999a-322b3eeae281', '8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of aFUEdN', 'beca035a-6bef-41c1-93e5-ae43872c0c8f');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('98e473aa-2d20-45f9-8715-f87e4e1b4c10', 'd4216af8-f6de-4b10-b3a0-b8b5ec2357b7', 'd61fd4f1-352a-4e7f-a0c2-5d7ada20570e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of ZAxLGU', '2d9d58ff-f7d7-40c1-9e39-9bbdb011cc1b');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('a133dec6-7d1a-485c-ab80-6c5d6ed980a9', '295166c1-e0fc-405e-ab7f-ce8ccfb98f9f', '8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of LQUJxM', 'af3c30f1-1864-4214-a470-3a6384a68d0e');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('a3003dca-648d-4e75-ae32-f1d09d091e70', '6e609695-3277-4572-82fb-d4f8f7ddaf47', '8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of gLjfOL', '66f425b9-cc91-4d7c-bff5-b84a49a32331');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('ab71b286-18ef-45a9-b0f2-4d8ed0dca6d5', '2885cc04-9a6d-4e27-b195-873fb9ed6006', 'a96f0ada-2a48-4792-a13f-0875c17a54ba', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of uENhpR', 'c7c7ab42-1fab-4bbd-b409-c4b09ba2f540');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('ac5326df-a4b8-4230-af39-10247cf2a3eb', '1752f8ea-2cc0-4068-8a2c-d4a1e640503f', 'a96f0ada-2a48-4792-a13f-0875c17a54ba', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of AbXQxT', '88dcb8ea-e774-4bd4-82ab-9870ee8b4680');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('acd9a991-7687-42d8-843b-7ae38d32fa23', '6e609695-3277-4572-82fb-d4f8f7ddaf47', '8e2f9809-ca64-4c0b-be9d-93dcbadf32a7', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of aiwUmw', '07491ae5-ae2b-45ad-90db-a548f5311fa2');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('acdbeb8f-3c4a-4d95-a76b-46be63aec1fc', '438b29e7-7009-44a2-8746-c33e1bc4fd05', '791daf36-d1c5-4453-9bfe-2f509894f43f', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of xrYsdo', 'e202448d-ade7-45c6-904e-862121f51b62');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('b1d0979c-8413-40f1-98db-706b92784514', 'cec8688b-4d51-4bad-b8b1-561203ad02f6', '3bf4b91d-cf09-4b4d-8f2f-1e967f36ef23', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of MEWvEA', 'b346e7d2-2ea0-4785-82b2-0835c4ec1388');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('b9243c9b-ca46-466d-b6c9-faa20239513f', '2885cc04-9a6d-4e27-b195-873fb9ed6006', '3bf4b91d-cf09-4b4d-8f2f-1e967f36ef23', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of zWioog', '5f2a6b94-28f2-4036-84d1-6655ad754538');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('bad7425b-7788-41ab-8a92-70480911ba02', 'e843df9f-97aa-484e-8695-42628efe3c10', 'b929ed6f-9fd2-44ef-bc38-7c291ac994bf', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of BDJFdd', 'c8d9c72d-f99a-41c9-ba35-195684f8f9be');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('bc338b35-613b-4192-8167-784ec63bd08d', 'bc71607b-a8e3-4bc8-9e59-23ce339a454c', '8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of yhDkJx', '2336ca2d-7566-43df-9d02-d0926279059c');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('c0248ffa-37ff-41ac-95cf-db9fc49cc8bd', '2885cc04-9a6d-4e27-b195-873fb9ed6006', '8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of VJjdgG', 'e98be11e-ff44-4e05-a1a9-c5c4df7e1fbf');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('c35333f4-da74-405a-a0f8-778cb977d9ac', '73944100-895d-4adf-9932-657d43476888', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of ftbBdi', 'db31846a-08a0-4745-baab-8ec8404a9c6b');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('c908f45a-132e-46f5-bd22-12a1ad8ffae4', '2885cc04-9a6d-4e27-b195-873fb9ed6006', 'ada13721-da9a-48ef-bb10-99c2ac3ab1a5', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of VhMhHo', '54ff243f-4c44-4b60-91b9-cb6be6a1a59d');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('ca3dd844-47c0-474d-85b8-7f095f86d0cc', '6e609695-3277-4572-82fb-d4f8f7ddaf47', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of oymDBL', '4f207041-33d9-4dab-a8ff-8d6a16c378c8');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('d9f73e0b-6966-4b31-80f0-796194e72788', '17804eaa-5545-43ff-999a-322b3eeae281', '91b147da-00e6-403f-9656-3c1ce0ea1f7b', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of FIkLQK', 'b6209f1c-aaa1-405b-8c1b-b761c2f8343e');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('e7db6a89-3244-468b-83ad-618cb78c32bb', 'd9f732c2-370f-4536-8385-e9028ceb0f00', 'd61fd4f1-352a-4e7f-a0c2-5d7ada20570e', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of PGFIbb', '3a24b7ff-096b-44bc-80e2-a302ff25e895');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('e9437046-25e3-4514-9560-35c52f4610be', 'ff71d771-57a7-437a-a6ad-d81b7df8849c', 'b929ed6f-9fd2-44ef-bc38-7c291ac994bf', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of RMKXUG', 'f13c8138-1432-4cd0-8646-7e32a8098dc1');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('f50bf2c1-6457-41c6-bbae-7073652696c3', '12a5942f-9853-454c-baf7-96e232389935', '26da8ff8-4eae-4b1d-af1a-0e5aecdf6ff0', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of reaFoB', 'd6f385e3-fbcd-4c07-abf4-71d541ff2858');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('f6d0520b-2498-4a6f-bd6e-ecf153bf8435', 'cec8688b-4d51-4bad-b8b1-561203ad02f6', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of xmcXPn', 'c5864a88-eef3-4f32-b816-79fc02b37a28');
INSERT INTO "Classes" ("ClassId", "DisciplineId", "GradeId", "ImageUrl", "Title", "UserId")
VALUES ('f6ebc2d6-500f-4fb5-b907-8878f783ca4d', 'da2a943c-8ea5-4ada-a6b4-12b14a9ac641', '6340d28b-2407-4bf5-9cd7-9881bdf35897', 'https://s3.eu-north-1.amazonaws.com/hiclass.images/default/default-class.jpg', 'Class of tKuHKv', '4c152dcf-9d6b-4a15-a109-ba38ecef0a4f');

INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('6e609695-3277-4572-82fb-d4f8f7ddaf47', '07491ae5-ae2b-45ad-90db-a548f5311fa2');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('bc71607b-a8e3-4bc8-9e59-23ce339a454c', '2336ca2d-7566-43df-9d02-d0926279059c');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('d4216af8-f6de-4b10-b3a0-b8b5ec2357b7', '2d9d58ff-f7d7-40c1-9e39-9bbdb011cc1b');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('295166c1-e0fc-405e-ab7f-ce8ccfb98f9f', '2eabce75-aa9c-40de-bf64-3d7a722d790c');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('d9f732c2-370f-4536-8385-e9028ceb0f00', '3a24b7ff-096b-44bc-80e2-a302ff25e895');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('89e95ed1-8088-4340-ab37-1386de70fdd8', '3d39d3f4-94e6-426a-93e9-39eb65fc10e0');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('da2a943c-8ea5-4ada-a6b4-12b14a9ac641', '4c152dcf-9d6b-4a15-a109-ba38ecef0a4f');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('6e609695-3277-4572-82fb-d4f8f7ddaf47', '4f207041-33d9-4dab-a8ff-8d6a16c378c8');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('e3fc8b5a-bc11-4ab4-bb40-d7503d7de16a', '519bfc2e-78e8-49b0-a501-1261f211e260');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('17804eaa-5545-43ff-999a-322b3eeae281', '53645d80-1a98-421a-b4eb-998283f44c76');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('2885cc04-9a6d-4e27-b195-873fb9ed6006', '54ff243f-4c44-4b60-91b9-cb6be6a1a59d');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('2885cc04-9a6d-4e27-b195-873fb9ed6006', '5f2a6b94-28f2-4036-84d1-6655ad754538');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('6e609695-3277-4572-82fb-d4f8f7ddaf47', '66f425b9-cc91-4d7c-bff5-b84a49a32331');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('1752f8ea-2cc0-4068-8a2c-d4a1e640503f', '69747c3f-374a-40aa-8c5c-abc1e59c6ab8');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('89e95ed1-8088-4340-ab37-1386de70fdd8', '77dc9df5-b30b-4f3a-8ce5-0ee4f7393766');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('015fa99f-240f-417c-be8e-d7c439121174', '7b8196ba-ba49-4c9f-9c3b-620dd888693f');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('d9f732c2-370f-4536-8385-e9028ceb0f00', '7ea4e7a9-8e85-47de-8082-ba2c393d4bbd');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('1752f8ea-2cc0-4068-8a2c-d4a1e640503f', '88dcb8ea-e774-4bd4-82ab-9870ee8b4680');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('f243d0b6-9462-4190-ba6d-b2b54433d512', '8deca522-cde1-4712-9ec3-0079d21b69cd');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('ff71d771-57a7-437a-a6ad-d81b7df8849c', '93a39fec-228b-4114-9dd6-5e036fcf0903');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('9e12b5c1-2aa5-4568-940e-db882e03e2e5', 'a64f5b1f-dd98-40a2-9246-0e49b8af93ab');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('295166c1-e0fc-405e-ab7f-ce8ccfb98f9f', 'af3c30f1-1864-4214-a470-3a6384a68d0e');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('5533de6f-51dc-4c9b-b38e-5f10f03ad259', 'b0fb5d0f-2c35-429b-90b7-2b21b4994118');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('cec8688b-4d51-4bad-b8b1-561203ad02f6', 'b346e7d2-2ea0-4785-82b2-0835c4ec1388');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('17804eaa-5545-43ff-999a-322b3eeae281', 'b6209f1c-aaa1-405b-8c1b-b761c2f8343e');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('78bd3361-7a78-4dcc-98e9-9c5071facfee', 'bde98c77-f917-453c-8455-d8529c72b945');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('17804eaa-5545-43ff-999a-322b3eeae281', 'beca035a-6bef-41c1-93e5-ae43872c0c8f');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('cec8688b-4d51-4bad-b8b1-561203ad02f6', 'c5864a88-eef3-4f32-b816-79fc02b37a28');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('2885cc04-9a6d-4e27-b195-873fb9ed6006', 'c781adf0-0f88-42db-9131-7a7a1c6712bf');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('2885cc04-9a6d-4e27-b195-873fb9ed6006', 'c7c7ab42-1fab-4bbd-b409-c4b09ba2f540');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('e843df9f-97aa-484e-8695-42628efe3c10', 'c8d9c72d-f99a-41c9-ba35-195684f8f9be');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('2885cc04-9a6d-4e27-b195-873fb9ed6006', 'cd0e6a13-f0f3-47dd-b1b3-022d429be1dc');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('12a5942f-9853-454c-baf7-96e232389935', 'd6f385e3-fbcd-4c07-abf4-71d541ff2858');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('73944100-895d-4adf-9932-657d43476888', 'db31846a-08a0-4745-baab-8ec8404a9c6b');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('4c616c7f-ab5d-4813-a751-3b2a18470971', 'dbc4cd6c-406a-4e1b-9355-e7bb2bdb51cd');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('438b29e7-7009-44a2-8746-c33e1bc4fd05', 'e202448d-ade7-45c6-904e-862121f51b62');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('2885cc04-9a6d-4e27-b195-873fb9ed6006', 'e98be11e-ff44-4e05-a1a9-c5c4df7e1fbf');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('5533de6f-51dc-4c9b-b38e-5f10f03ad259', 'eb159b1d-72e7-4fa4-99bd-02190ac52469');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('ff71d771-57a7-437a-a6ad-d81b7df8849c', 'f13c8138-1432-4cd0-8646-7e32a8098dc1');
INSERT INTO "UserDisciplines" ("DisciplineId", "UserId")
VALUES ('ff71d771-57a7-437a-a6ad-d81b7df8849c', 'f7882287-6b00-4c5e-b8cb-6e4fe57c460c');

INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8e2f9809-ca64-4c0b-be9d-93dcbadf32a7', '07491ae5-ae2b-45ad-90db-a548f5311fa2');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', '2336ca2d-7566-43df-9d02-d0926279059c');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('d61fd4f1-352a-4e7f-a0c2-5d7ada20570e', '2d9d58ff-f7d7-40c1-9e39-9bbdb011cc1b');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', '2eabce75-aa9c-40de-bf64-3d7a722d790c');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('d61fd4f1-352a-4e7f-a0c2-5d7ada20570e', '3a24b7ff-096b-44bc-80e2-a302ff25e895');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', '3d39d3f4-94e6-426a-93e9-39eb65fc10e0');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', '4c152dcf-9d6b-4a15-a109-ba38ecef0a4f');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', '4f207041-33d9-4dab-a8ff-8d6a16c378c8');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('791daf36-d1c5-4453-9bfe-2f509894f43f', '519bfc2e-78e8-49b0-a501-1261f211e260');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('a96f0ada-2a48-4792-a13f-0875c17a54ba', '53645d80-1a98-421a-b4eb-998283f44c76');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('ada13721-da9a-48ef-bb10-99c2ac3ab1a5', '54ff243f-4c44-4b60-91b9-cb6be6a1a59d');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('3bf4b91d-cf09-4b4d-8f2f-1e967f36ef23', '5f2a6b94-28f2-4036-84d1-6655ad754538');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', '66f425b9-cc91-4d7c-bff5-b84a49a32331');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('791daf36-d1c5-4453-9bfe-2f509894f43f', '69747c3f-374a-40aa-8c5c-abc1e59c6ab8');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', '77dc9df5-b30b-4f3a-8ce5-0ee4f7393766');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', '7b8196ba-ba49-4c9f-9c3b-620dd888693f');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', '7ea4e7a9-8e85-47de-8082-ba2c393d4bbd');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('a96f0ada-2a48-4792-a13f-0875c17a54ba', '88dcb8ea-e774-4bd4-82ab-9870ee8b4680');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('ada13721-da9a-48ef-bb10-99c2ac3ab1a5', '8deca522-cde1-4712-9ec3-0079d21b69cd');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('91b147da-00e6-403f-9656-3c1ce0ea1f7b', '93a39fec-228b-4114-9dd6-5e036fcf0903');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('ada13721-da9a-48ef-bb10-99c2ac3ab1a5', 'a64f5b1f-dd98-40a2-9246-0e49b8af93ab');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'af3c30f1-1864-4214-a470-3a6384a68d0e');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('91b147da-00e6-403f-9656-3c1ce0ea1f7b', 'b0fb5d0f-2c35-429b-90b7-2b21b4994118');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('3bf4b91d-cf09-4b4d-8f2f-1e967f36ef23', 'b346e7d2-2ea0-4785-82b2-0835c4ec1388');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('91b147da-00e6-403f-9656-3c1ce0ea1f7b', 'b6209f1c-aaa1-405b-8c1b-b761c2f8343e');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'bde98c77-f917-453c-8455-d8529c72b945');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'beca035a-6bef-41c1-93e5-ae43872c0c8f');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', 'c5864a88-eef3-4f32-b816-79fc02b37a28');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('d61fd4f1-352a-4e7f-a0c2-5d7ada20570e', 'c781adf0-0f88-42db-9131-7a7a1c6712bf');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('a96f0ada-2a48-4792-a13f-0875c17a54ba', 'c7c7ab42-1fab-4bbd-b409-c4b09ba2f540');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('b929ed6f-9fd2-44ef-bc38-7c291ac994bf', 'c8d9c72d-f99a-41c9-ba35-195684f8f9be');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('ada13721-da9a-48ef-bb10-99c2ac3ab1a5', 'cd0e6a13-f0f3-47dd-b1b3-022d429be1dc');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('26da8ff8-4eae-4b1d-af1a-0e5aecdf6ff0', 'd6f385e3-fbcd-4c07-abf4-71d541ff2858');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', 'db31846a-08a0-4745-baab-8ec8404a9c6b');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('3bf4b91d-cf09-4b4d-8f2f-1e967f36ef23', 'dbc4cd6c-406a-4e1b-9355-e7bb2bdb51cd');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('791daf36-d1c5-4453-9bfe-2f509894f43f', 'e202448d-ade7-45c6-904e-862121f51b62');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('8a2ec320-60a0-4938-8ff5-99adbdfaee6e', 'e98be11e-ff44-4e05-a1a9-c5c4df7e1fbf');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('1253bf02-ead4-4b35-932e-e8bd142c6787', 'eb159b1d-72e7-4fa4-99bd-02190ac52469');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('b929ed6f-9fd2-44ef-bc38-7c291ac994bf', 'f13c8138-1432-4cd0-8646-7e32a8098dc1');
INSERT INTO "UserGrades" ("GradeId", "UserId")
VALUES ('6340d28b-2407-4bf5-9cd7-9881bdf35897', 'f7882287-6b00-4c5e-b8cb-6e4fe57c460c');

INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a2de0434-2f8f-4166-be19-3d76f5f83fd9', '07491ae5-ae2b-45ad-90db-a548f5311fa2');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('9b3bac73-5c09-4adf-adfb-87f371b3cc3f', '2336ca2d-7566-43df-9d02-d0926279059c');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a663abf7-d16c-4277-a996-9ff9415567a5', '2d9d58ff-f7d7-40c1-9e39-9bbdb011cc1b');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a663abf7-d16c-4277-a996-9ff9415567a5', '2eabce75-aa9c-40de-bf64-3d7a722d790c');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('9b3bac73-5c09-4adf-adfb-87f371b3cc3f', '3a24b7ff-096b-44bc-80e2-a302ff25e895');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a663abf7-d16c-4277-a996-9ff9415567a5', '3d39d3f4-94e6-426a-93e9-39eb65fc10e0');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a663abf7-d16c-4277-a996-9ff9415567a5', '4c152dcf-9d6b-4a15-a109-ba38ecef0a4f');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('70ac3a7a-6a0a-47a9-b350-d7bb69058c45', '4f207041-33d9-4dab-a8ff-8d6a16c378c8');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('8650489d-76a1-482a-aa73-db1c61e85010', '519bfc2e-78e8-49b0-a501-1261f211e260');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('9b3bac73-5c09-4adf-adfb-87f371b3cc3f', '53645d80-1a98-421a-b4eb-998283f44c76');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('8ab2784d-53fb-4f0c-be8d-ea0bce40ec61', '54ff243f-4c44-4b60-91b9-cb6be6a1a59d');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('b60d1166-529b-4697-88bf-bd28fae6b742', '5f2a6b94-28f2-4036-84d1-6655ad754538');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('c429260b-9a74-4b3d-a803-6bea12f1dac6', '66f425b9-cc91-4d7c-bff5-b84a49a32331');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('b60d1166-529b-4697-88bf-bd28fae6b742', '69747c3f-374a-40aa-8c5c-abc1e59c6ab8');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('c2d2bbb9-4140-4ff1-979d-47da41e7d79b', '77dc9df5-b30b-4f3a-8ce5-0ee4f7393766');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('8650489d-76a1-482a-aa73-db1c61e85010', '7b8196ba-ba49-4c9f-9c3b-620dd888693f');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a2de0434-2f8f-4166-be19-3d76f5f83fd9', '7ea4e7a9-8e85-47de-8082-ba2c393d4bbd');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('c429260b-9a74-4b3d-a803-6bea12f1dac6', '88dcb8ea-e774-4bd4-82ab-9870ee8b4680');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('ccad397e-ed67-4872-9b01-05666b29d1dd', '8deca522-cde1-4712-9ec3-0079d21b69cd');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a663abf7-d16c-4277-a996-9ff9415567a5', '93a39fec-228b-4114-9dd6-5e036fcf0903');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('c2d2bbb9-4140-4ff1-979d-47da41e7d79b', 'a64f5b1f-dd98-40a2-9246-0e49b8af93ab');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('9b3bac73-5c09-4adf-adfb-87f371b3cc3f', 'af3c30f1-1864-4214-a470-3a6384a68d0e');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('72ce4328-7613-4d9c-b606-378f0441c207', 'b0fb5d0f-2c35-429b-90b7-2b21b4994118');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('8650489d-76a1-482a-aa73-db1c61e85010', 'b346e7d2-2ea0-4785-82b2-0835c4ec1388');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('05c314f5-89ec-4399-8e22-8758b261a788', 'b6209f1c-aaa1-405b-8c1b-b761c2f8343e');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('9b3bac73-5c09-4adf-adfb-87f371b3cc3f', 'bde98c77-f917-453c-8455-d8529c72b945');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('8ab2784d-53fb-4f0c-be8d-ea0bce40ec61', 'beca035a-6bef-41c1-93e5-ae43872c0c8f');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('c429260b-9a74-4b3d-a803-6bea12f1dac6', 'c5864a88-eef3-4f32-b816-79fc02b37a28');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('c429260b-9a74-4b3d-a803-6bea12f1dac6', 'c781adf0-0f88-42db-9131-7a7a1c6712bf');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('8ab2784d-53fb-4f0c-be8d-ea0bce40ec61', 'c7c7ab42-1fab-4bbd-b409-c4b09ba2f540');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('ccad397e-ed67-4872-9b01-05666b29d1dd', 'c8d9c72d-f99a-41c9-ba35-195684f8f9be');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('9b3bac73-5c09-4adf-adfb-87f371b3cc3f', 'cd0e6a13-f0f3-47dd-b1b3-022d429be1dc');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('70ac3a7a-6a0a-47a9-b350-d7bb69058c45', 'd6f385e3-fbcd-4c07-abf4-71d541ff2858');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('72ce4328-7613-4d9c-b606-378f0441c207', 'db31846a-08a0-4745-baab-8ec8404a9c6b');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('72ce4328-7613-4d9c-b606-378f0441c207', 'dbc4cd6c-406a-4e1b-9355-e7bb2bdb51cd');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('70ac3a7a-6a0a-47a9-b350-d7bb69058c45', 'e202448d-ade7-45c6-904e-862121f51b62');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('72ce4328-7613-4d9c-b606-378f0441c207', 'e98be11e-ff44-4e05-a1a9-c5c4df7e1fbf');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('c2d2bbb9-4140-4ff1-979d-47da41e7d79b', 'eb159b1d-72e7-4fa4-99bd-02190ac52469');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('a463d76a-cbc1-4914-a0ce-dac72dbba114', 'f13c8138-1432-4cd0-8646-7e32a8098dc1');
INSERT INTO "UserLanguages" ("LanguageId", "UserId")
VALUES ('4580a4ce-d0d7-490c-a084-522a3429fa3f', 'f7882287-6b00-4c5e-b8cb-6e4fe57c460c');

INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('d9f73e0b-6966-4b31-80f0-796194e72788', '05c314f5-89ec-4399-8e22-8758b261a788');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('4a3b8658-0b18-4525-819b-9c1fc2ce6cfc', '4580a4ce-d0d7-490c-a084-522a3429fa3f');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('acdbeb8f-3c4a-4d95-a76b-46be63aec1fc', '70ac3a7a-6a0a-47a9-b350-d7bb69058c45');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('ca3dd844-47c0-474d-85b8-7f095f86d0cc', '70ac3a7a-6a0a-47a9-b350-d7bb69058c45');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('f50bf2c1-6457-41c6-bbae-7073652696c3', '70ac3a7a-6a0a-47a9-b350-d7bb69058c45');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('3389e490-c298-4c88-a99d-20816e644fcb', '72ce4328-7613-4d9c-b606-378f0441c207');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('78b86af4-a3e3-4749-b9e3-53ea68015ada', '72ce4328-7613-4d9c-b606-378f0441c207');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('c0248ffa-37ff-41ac-95cf-db9fc49cc8bd', '72ce4328-7613-4d9c-b606-378f0441c207');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('c35333f4-da74-405a-a0f8-778cb977d9ac', '72ce4328-7613-4d9c-b606-378f0441c207');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('1c65a2b6-42a3-4429-8fc3-baa3fe101be0', '8650489d-76a1-482a-aa73-db1c61e85010');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('61822433-c9f9-480a-823a-9b927c288e28', '8650489d-76a1-482a-aa73-db1c61e85010');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('b1d0979c-8413-40f1-98db-706b92784514', '8650489d-76a1-482a-aa73-db1c61e85010');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('8d028061-4694-4e6d-bbd3-4fa9f4d3d391', '8ab2784d-53fb-4f0c-be8d-ea0bce40ec61');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('ab71b286-18ef-45a9-b0f2-4d8ed0dca6d5', '8ab2784d-53fb-4f0c-be8d-ea0bce40ec61');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('c908f45a-132e-46f5-bd22-12a1ad8ffae4', '8ab2784d-53fb-4f0c-be8d-ea0bce40ec61');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('112ed03c-8e96-494c-8df1-f371684da2da', '9b3bac73-5c09-4adf-adfb-87f371b3cc3f');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('1d01e0ab-eeb5-430f-a6ea-bd6584d92ea8', '9b3bac73-5c09-4adf-adfb-87f371b3cc3f');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('1e03add8-94e0-48ac-9b39-d8064afe7f74', '9b3bac73-5c09-4adf-adfb-87f371b3cc3f');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('a133dec6-7d1a-485c-ab80-6c5d6ed980a9', '9b3bac73-5c09-4adf-adfb-87f371b3cc3f');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('bc338b35-613b-4192-8167-784ec63bd08d', '9b3bac73-5c09-4adf-adfb-87f371b3cc3f');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('e7db6a89-3244-468b-83ad-618cb78c32bb', '9b3bac73-5c09-4adf-adfb-87f371b3cc3f');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('0ff3ced7-8fe4-4ca8-acd1-234bb112f6fb', 'a2de0434-2f8f-4166-be19-3d76f5f83fd9');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('acd9a991-7687-42d8-843b-7ae38d32fa23', 'a2de0434-2f8f-4166-be19-3d76f5f83fd9');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('e9437046-25e3-4514-9560-35c52f4610be', 'a463d76a-cbc1-4914-a0ce-dac72dbba114');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('0e70ed51-320f-4819-9c80-d1e9dd78b7e6', 'a663abf7-d16c-4277-a996-9ff9415567a5');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('170ff2c1-5fb1-488a-8901-a991babb6263', 'a663abf7-d16c-4277-a996-9ff9415567a5');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('53a09989-e812-406a-9697-a43340cc2c35', 'a663abf7-d16c-4277-a996-9ff9415567a5');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('98e473aa-2d20-45f9-8715-f87e4e1b4c10', 'a663abf7-d16c-4277-a996-9ff9415567a5');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('f6ebc2d6-500f-4fb5-b907-8878f783ca4d', 'a663abf7-d16c-4277-a996-9ff9415567a5');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('7fae7fd3-2506-4bc6-abef-76c0bb24cffc', 'b60d1166-529b-4697-88bf-bd28fae6b742');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('b9243c9b-ca46-466d-b6c9-faa20239513f', 'b60d1166-529b-4697-88bf-bd28fae6b742');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('2f74db29-ede9-47f4-9e65-46fcabecf427', 'c2d2bbb9-4140-4ff1-979d-47da41e7d79b');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('3ea7f580-e018-45da-9647-44f4958237ce', 'c2d2bbb9-4140-4ff1-979d-47da41e7d79b');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('44652512-35dc-4433-801f-ccb53458815d', 'c2d2bbb9-4140-4ff1-979d-47da41e7d79b');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('6d982b18-9790-4d6d-b15a-9bd71a6f68cb', 'c429260b-9a74-4b3d-a803-6bea12f1dac6');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('a3003dca-648d-4e75-ae32-f1d09d091e70', 'c429260b-9a74-4b3d-a803-6bea12f1dac6');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('ac5326df-a4b8-4230-af39-10247cf2a3eb', 'c429260b-9a74-4b3d-a803-6bea12f1dac6');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('f6d0520b-2498-4a6f-bd6e-ecf153bf8435', 'c429260b-9a74-4b3d-a803-6bea12f1dac6');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('121e8327-68ae-4de5-80a5-602c9f3088bd', 'ccad397e-ed67-4872-9b01-05666b29d1dd');
INSERT INTO "ClassLanguages" ("ClassId", "LanguageId")
VALUES ('bad7425b-7788-41ab-8a92-70480911ba02', 'ccad397e-ed67-4872-9b01-05666b29d1dd');

CREATE UNIQUE INDEX "IX_Cities_CityId" ON "Cities" ("CityId");

CREATE INDEX "IX_Cities_CountryId" ON "Cities" ("CountryId");

CREATE UNIQUE INDEX "IX_Cities_Title_CountryId" ON "Cities" ("Title", "CountryId");

CREATE UNIQUE INDEX "IX_Classes_ClassId" ON "Classes" ("ClassId");

CREATE INDEX "IX_Classes_DisciplineId" ON "Classes" ("DisciplineId");

CREATE INDEX "IX_Classes_GradeId" ON "Classes" ("GradeId");

CREATE INDEX "IX_Classes_UserId" ON "Classes" ("UserId");

CREATE INDEX "IX_ClassLanguages_ClassId" ON "ClassLanguages" ("ClassId");

CREATE UNIQUE INDEX "IX_ClassLanguages_LanguageId_ClassId" ON "ClassLanguages" ("LanguageId", "ClassId");

CREATE UNIQUE INDEX "IX_Countries_CountryId" ON "Countries" ("CountryId");

CREATE UNIQUE INDEX "IX_Countries_Title" ON "Countries" ("Title");

CREATE UNIQUE INDEX "IX_Devices_DeviceId" ON "Devices" ("DeviceId");

CREATE UNIQUE INDEX "IX_Devices_DeviceToken" ON "Devices" ("DeviceToken");

CREATE UNIQUE INDEX "IX_Disciplines_DisciplineId" ON "Disciplines" ("DisciplineId");

CREATE UNIQUE INDEX "IX_Feedbacks_FeedbackId" ON "Feedbacks" ("FeedbackId");

CREATE INDEX "IX_Feedbacks_InvitationId" ON "Feedbacks" ("InvitationId");

CREATE INDEX "IX_Feedbacks_UserFeedbackReceiverId" ON "Feedbacks" ("UserFeedbackReceiverId");

CREATE INDEX "IX_Feedbacks_UserFeedbackSenderId" ON "Feedbacks" ("UserFeedbackSenderId");

CREATE UNIQUE INDEX "IX_Grades_GradeId" ON "Grades" ("GradeId");

CREATE UNIQUE INDEX "IX_Grades_GradeNumber" ON "Grades" ("GradeNumber");

CREATE UNIQUE INDEX "IX_Institutions_InstitutionId" ON "Institutions" ("InstitutionId");

CREATE UNIQUE INDEX "IX_InstitutionTypes_InstitutionTypeId" ON "InstitutionTypes" ("InstitutionTypeId");

CREATE INDEX "IX_InstitutionTypesInstitutions_InstitutionId" ON "InstitutionTypesInstitutions" ("InstitutionId");

CREATE UNIQUE INDEX "IX_InstitutionTypesInstitutions_InstitutionTypeId_InstitutionId" ON "InstitutionTypesInstitutions" ("InstitutionTypeId", "InstitutionId");

CREATE INDEX "IX_Invitations_ClassRecipientId" ON "Invitations" ("ClassRecipientId");

CREATE INDEX "IX_Invitations_ClassSenderId" ON "Invitations" ("ClassSenderId");

CREATE UNIQUE INDEX "IX_Invitations_InvitationId" ON "Invitations" ("InvitationId");

CREATE INDEX "IX_Invitations_UserRecipientId" ON "Invitations" ("UserRecipientId");

CREATE INDEX "IX_Invitations_UserSenderId" ON "Invitations" ("UserSenderId");

CREATE UNIQUE INDEX "IX_Languages_LanguageId" ON "Languages" ("LanguageId");

CREATE INDEX "IX_Notifications_UserReceiverId" ON "Notifications" ("UserReceiverId");

CREATE UNIQUE INDEX "IX_Roles_RoleId" ON "Roles" ("RoleId");

CREATE INDEX "IX_UserDevices_DeviceId" ON "UserDevices" ("DeviceId");

CREATE UNIQUE INDEX "IX_UserDevices_UserId_DeviceId" ON "UserDevices" ("UserId", "DeviceId");

CREATE INDEX "IX_UserDisciplines_DisciplineId" ON "UserDisciplines" ("DisciplineId");

CREATE UNIQUE INDEX "IX_UserDisciplines_UserId_DisciplineId" ON "UserDisciplines" ("UserId", "DisciplineId");

CREATE INDEX "IX_UserGrades_GradeId" ON "UserGrades" ("GradeId");

CREATE UNIQUE INDEX "IX_UserGrades_UserId_GradeId" ON "UserGrades" ("UserId", "GradeId");

CREATE INDEX "IX_UserLanguages_LanguageId" ON "UserLanguages" ("LanguageId");

CREATE UNIQUE INDEX "IX_UserLanguages_UserId_LanguageId" ON "UserLanguages" ("UserId", "LanguageId");

CREATE INDEX "IX_UserRoles_RoleId" ON "UserRoles" ("RoleId");

CREATE UNIQUE INDEX "IX_UserRoles_UserId_RoleId" ON "UserRoles" ("UserId", "RoleId");

CREATE INDEX "IX_Users_CityId" ON "Users" ("CityId");

CREATE INDEX "IX_Users_CountryId" ON "Users" ("CountryId");

CREATE UNIQUE INDEX "IX_Users_Email" ON "Users" ("Email");

CREATE INDEX "IX_Users_InstitutionId" ON "Users" ("InstitutionId");

CREATE UNIQUE INDEX "IX_Users_UserId" ON "Users" ("UserId");

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20240922132400_Initial', '6.0.26');

COMMIT;

