	DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
COMMENT ON SCHEMA public IS 'standard public schema';
DROP TYPE IF EXISTS GenderS CASCADE;
CREATE TYPE GenderS AS ENUM ('MALE','FEMALE');
DROP TYPE IF EXISTS WorkStatusS CASCADE;
CREATE TYPE  WorkStatusS AS ENUM ('CURRENT','PAST');
DROP TYPE IF EXISTS theStatusS CASCADE;
CREATE TYPE theStatusS AS ENUM ('PENDING','ACCEPTED','REJECTED'); 
DROP TYPE IF EXISTS reqStatusS CASCADE;
CREATE TYPE reqStatusS AS ENUM ('PENDING','REPLIED');
DROP TYPE IF EXISTS specialWorkCapabilityS CASCADE;
CREATE TYPE specialWorkCapabilityS AS ENUM ('NONE','REMOTED_WORK'); 

CREATE TABLE IF NOT EXISTS public."Member" (
    email varchar(30)  PRIMARY KEY,
    firstName varchar(15) NOT NULL,
    secondName varchar(20) NOT NULL,
    thePassword varchar(15) NOT NULL,
    subscriptionExpiry date NOT NULL,
    dateOfBirth date NOT NULL,
    country varchar(20) NOT NULL,
    postalCode integer NOT NULL,
    gender genders NOT NULL,
    lastLoginDate date NOT NULL
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);
CREATE TABLE IF NOT EXISTS public."Category" (
    categoryID integer PRIMARY KEY,
    Aname varchar(45) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Connects" (
    email varchar(30) references public."Member" (email) NOT NULL,
    connectedWith_email varchar(30) references public."Member" (email) NOT NULL,
    AType varchar(30) ,
    theComment varchar(300) ,
    dateOfJoin date NOT NULL,
    PRIMARY KEY(email,connectedWith_Email)
);
CREATE TABLE IF NOT EXISTS public."Experience" (
    ExperienceID smallint PRIMARY KEY,
    company varchar(100) NOT NULL,
    WorkStatus WorkStatusS DEFAULT 'PAST',
    title varchar(30) NOT NULL,
    description varchar(400) NOT NULL,
    fromYear smallint NOT NULL,
    toYear smallint NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL UNIQUE	
);
CREATE TABLE IF NOT EXISTS public."Invitation" (
    invitationID smallint PRIMARY KEY,
    dateSent date NOT NULL,
    theStatus theStatusS DEFAULT 'PENDING',
    sender_Email varchar(30) references public."Member" (email) NOT NULL,
    receiver_Email varchar(30) references public."Member" (email) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Msg" (
    msgID smallint PRIMARY KEY,
    dateSent date NOT NULL,
    theSubject varchar(40) NOT NULL,
    theText varchar(4000) NOT NULL,
    sender_Email varchar(30) references public."Member" (email) NOT NULL,
    receiver_Email varchar(30) references public."Member" (email) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Recommendation_Request" (
    requestID smallint PRIMARY KEY,
    dateSent date NOT NULL,
    theStatus reqStatusS DEFAULT 'PENDING',
    for_email varchar(30) references public."Member" (email) NOT NULL,
    sender_email varchar(30) references public."Member" (email) NOT NULL,
    receiver_email varchar(30) references public."Member" (email) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Recommendation_Msg" (
    recommendation_msg_ID smallint PRIMARY KEY,
    dateSent date NOT NULL,
    description varchar(4000) NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL,
    requestID smallint references public."Recommendation_Request"(requestID) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS public."Endorses" (
    email varchar(30) references public."Member" (email) NOT NULL,
    recommended_email varchar(30) references public."Member" (email) NOT NULL,
    skills varchar(600) NOT NULL,
    datePosted date NOT NULL,
    PRIMARY KEY(email,recommended_email)
);
CREATE TABLE IF NOT EXISTS public."Additional_Info" (
    additionalinfoID smallint PRIMARY KEY,
    Assosiations varchar(200) NOT NULL,
    Awards varchar(200) NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Advertisment"(
    advertismentID smallint PRIMARY KEY,
    Salary varchar(10) NOT NULL,
    jobType varchar(15) NOT NULL,
    Industry varchar(25) NOT NULL,
    EduLevel varchar(20) NOT NULL,
    specialWorkCapability specialWorkCapabilityS DEFAULT 'NONE',
    title varchar(100) NOT NULL,
    ALocation varchar(50) NOT NULL,
    postalCode INTEGER NOT NULL,
    country varchar(20) NOT NULL,
    datePosted date NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Job_Offer" (
    advertismentID smallint references public."Advertisment" (advertismentID) PRIMARY KEY,
    JobDescription varchar(2000) NOT NULL,
    fromAge INTEGER NOT NULL,
    toAge INTEGER NOT NULL,
    company varchar(100) NOT NULL,
    companyURL varchar(30) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Job_Seek" (
    advertismentID smallint PRIMARY KEY references public."Advertisment" (advertismentID),
    PersonalDescription varchar(2000) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Member_Interests" (
    memberID varchar(30) references public."Member" (email) NOT NULL,
    interestID smallint NOT NULL,
    PRIMARY KEY(memberID,interestID)
);
CREATE TABLE IF NOT EXISTS public."Question" (
    questionID smallint PRIMARY KEY,
    question varchar(50) NOT NULL,
    datePosted date NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL,
    categoryID integer references public."Category" (categoryID) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Answer" (
    answerID smallint PRIMARY KEY,
    answer varchar(1000) NOT NULL,
    datePosted date NOT NULL,
    questionID smallint references public."Question" (questionID) NOT NULL,
    email varchar(30) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Summary" (
    Aheadline varchar(30) NOT NULL,
    Summary varchar(600) NOT NULL,
    specialWorkCapability specialWorkCapabilityS DEFAULT 'NONE',
    categoryID INTEGER references public."Category" (categoryID) NOT NULL,
    email varchar(30) references public."Member" (email) PRIMARY KEY
);
CREATE TABLE IF NOT EXISTS public."Article" (
    articleID smallint PRIMARY KEY,
    title varchar(40) NOT NULL,
    categoryID INTEGER references public."Category" (categoryID) NOT NULL,
    theText varchar(2000) NOT NULL,
    datePosted date NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL
);

CREATE TABLE IF NOT EXISTS public."Article_Comment" (
    commentID smallint PRIMARY KEY,
    theComment varchar(1000) NOT NULL,
    datePosted date NOT NULL,
    articleID smallint references public."Article" (articleID) NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL
);
CREATE TABLE IF NOT EXISTS public."Education" (
    educationID smallint PRIMARY KEY,
    country varchar(20) NOT NULL,
    school varchar(30) NOT NULL,
    EduLevel varchar(30) NOT NULL,
    categoryID INTEGER references public."Category" (categoryID) NOT NULL,
    fromYear smallint NOT NULL,
    toYear smallint NOT NULL,
    email varchar(30) references public."Member" (email) NOT NULL UNIQUE
);

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Data - Constraints - Functions 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--5
CREATE OR REPLACE FUNCTION data_contst_func_5() RETURNS trigger AS $BODY$
	DECLARE email1 varchar(30);
		email2 varchar(30);
		cnt integer;
	BEGIN
		email1 := NEW."sender_email";
		email2 := NEW."for_email";
		SELECT COUNT(email) INTO cnt FROM public."Connects" WHERE ( (email=email1 AND connectedWith_email=email2) OR (email=email2 AND connectedWith_email=email1));
		IF cnt <= 0 THEN 
			RAISE EXCEPTION '% , % havent connection level 1',email1,email2;
		END IF;
		RETURN NEW;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER data_contst_func_5 BEFORE INSERT ON public."Recommendation_Request" FOR EACH ROW EXECUTE PROCEDURE data_contst_func_5();

--6
CREATE OR REPLACE FUNCTION data_contst_func_6() RETURNS trigger AS $BODY$
	DECLARE cnt INTEGER;
	DECLARE t_email varchar(30);
	BEGIN
		SELECT email INTO t_email FROM public."Question" WHERE questionID = NEW.questionID;
		SELECT COUNT(*) INTO cnt FROM public."myview" WHERE email1 = t_email AND email2=NEW.email;
		IF cnt <=0 THEN
			RAISE EXCEPTION '% , % dont have any connection so % cant answer to this question',t_email,NEW.email,NEW.email;
		END IF;
		RETURN NEW;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER data_contst_func_6 BEFORE INSERT ON public."Answer" FOR EACH ROW EXECUTE PROCEDURE data_contst_func_6();

--7
CREATE OR REPLACE FUNCTION data_contst_func_7() RETURNS trigger AS $BODY$
	BEGIN
		IF NEW.theStatus = 'ACCEPTED' THEN
			INSERT INTO public."Connects"
			VALUES (NEW.sender_Email,NEW.receiver_Email,NULL,NULL,current_timestamp);
			INSERT INTO public."Connects"
			VALUES (NEW.receiver_Email,NEW.sender_Email,NULL,NULL,current_timestamp);
		END IF;
		RETURN NEW;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER data_contst_func_7 BEFORE UPDATE OF theStatus ON public."Invitation" FOR EACH ROW EXECUTE PROCEDURE data_contst_func_7();

--8
CREATE OR REPLACE FUNCTION data_contst_func_8() RETURNS trigger AS $BODY$
	BEGIN
		DELETE FROM public."Article_Comment" USING public."Article" WHERE public."Article_Comment".articleID = public."Article".articleID AND public."Article".dateposted < NOW() - INTERVAL '30 days';
		RETURN NEW;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER data_contst_func_8 BEFORE INSERT ON public."Article" FOR EACH ROW EXECUTE PROCEDURE data_contst_func_8();


--9 
CREATE OR REPLACE FUNCTION data_contst_func_9() RETURNS trigger AS $BODY$
	DECLARE t_sender_email varchar(30);
	DECLARE t_receiver_email varchar(30);
	DECLARE t_EduLevel varchar(30);
	DECLARE t_JobType varchar(30);
	BEGIN
		SELECT EduLevel INTO t_EduLevel FROM public."Advertisment" INNER JOIN public."Job_Offer"  ON public."Advertisment".advertismentID = NEW.advertismentID;
		SELECT jobType INTO t_JobType FROM public."Advertisment" INNER JOIN public."Job_Offer"  ON public."Advertisment".advertismentID = NEW.advertismentID;
		SELECT email INTO t_sender_email FROM public."Advertisment" INNER JOIN public."Job_Offer"  ON public."Advertisment".advertismentID = NEW.advertismentID;
		FOR t_receiver_email IN (SELECT email FROM public."Education" WHERE EduLevel = t_EduLevel UNION SELECT email FROM public."Experience" WHERE  title = t_JobType) LOOP
			INSERT INTO public."Msg"(msgID,dateSent,theSubject,theText,sender_email,receiver_email)
			VALUES((SELECT COUNT(*) FROM public."Msg")+1,NOW(),'NEW JOB OFFER',NEW.jobDescription,t_sender_email,t_receiver_email);
		END LOOP;
		RETURN NEW;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER data_contst_func_9 BEFORE INSERT OR UPDATE ON public."Job_Offer"  FOR EACH ROW EXECUTE PROCEDURE data_contst_func_9();


--10
CREATE OR REPLACE FUNCTION data_contst_func_10() RETURNS trigger AS $BODY$
	DECLARE t_sender_email varchar(30);
	DECLARE t_receiver_email varchar(30);
	DECLARE t_JobType varchar(30);
	BEGIN
		SELECT email INTO t_sender_email FROM public."Advertisment" INNER JOIN public."Job_Seek"  ON public."Advertisment".advertismentID = NEW.advertismentID;
		FOR t_receiver_email IN SELECT email FROM public."Advertisment" INNER JOIN public."Job_Seek"  ON public."Advertisment".advertismentID = NEW.advertismentID WHERE jobType = t_JobType LOOP
			INSERT INTO public."Msg"(msgID,dateSent,theSubject,theText,sender_email,receiver_email)
			VALUES((SELECT COUNT(*) FROM public."Msg")+1,NOW(),'MY RESUME',NEW.personalDescription,t_sender_email,t_receiver_email);
		END LOOP;
		RETURN NEW;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER data_contst_func_10 BEFORE INSERT OR UPDATE ON public."Job_Seek"  FOR EACH ROW EXECUTE PROCEDURE data_contst_func_10();


--11
CREATE OR REPLACE FUNCTION data_contst_func_11() RETURNS trigger AS $BODY$
	DECLARE t_email varchar(30);
	DECLARE t_id smallint;
	DECLARE r RECORD;
	BEGIN
		CREATE TABLE IF NOT EXISTS public."Logs"(
			ID smallint NOT NULL,
			oID smallint NOT NULL,
			DateDeleted date NOT NULL,
			ttype varchar(5) NOT NULL,
			Description varchar(2000) NOT NULL,
			fromAge  INTEGER,
			toAge INTEGER,
			company varchar(100),
			companyURL varchar(30)		
		);
		IF NEW.subscriptionExpiry < NEW.lastLoginDate THEN
			t_email:= NEW.email;
			FOR t_id IN SELECT advertismentID FROM public."Advertisment" WHERE email = t_email LOOP
				DELETE FROM public."Job_Seek" WHERE advertismentID = t_id;
				DELETE FROM public."Job_Offer" WHERE advertismentID = t_id;
			END LOOP;
		END IF; 
		RETURN NEW;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER data_contst_func_11 AFTER UPDATE OF lastLoginDate ON public."Member"  FOR EACH ROW EXECUTE PROCEDURE data_contst_func_11();


CREATE OR REPLACE FUNCTION on_delete_seek() RETURNS trigger AS $BODY$
	DECLARE t_date date;
	BEGIN 
		INSERT INTO public."Logs"(ID,oID,DateDeleted,ttype,Description,fromAge,toAge,company,companyURL)
		VALUES((SELECT COUNT(*) FROM public."Logs")+1,OLD.advertismentID,NOW(),'SEEK',OLD.personalDescription,NULL,NULL,NULL,NULL);
		RETURN OLD;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER on_delete_seek BEFORE DELETE ON public."Job_Seek"  FOR EACH ROW EXECUTE PROCEDURE on_delete_seek();

CREATE OR REPLACE FUNCTION on_delete_offer() RETURNS trigger AS $BODY$
	DECLARE t_date date;
	BEGIN 
		INSERT INTO public."Logs"(ID,oID,DateDeleted,ttype,Description,fromAge,toAge,company,companyURL)
		VALUES((SELECT COUNT(*) FROM public."Logs")+1,OLD.advertismentID,NOW(),'OFFER',OLD.jobDescription,OLD.fromAge,OLD.toAge,company,companyURL);
		RETURN OLD;
	END;
$BODY$ LANGUAGE 'plpgsql' ;
CREATE TRIGGER on_delete_offer BEFORE DELETE ON public."Job_Offer"  FOR EACH ROW EXECUTE PROCEDURE on_delete_offer();
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Views
-------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE RECURSIVE VIEW MyView(email1 ,email2 ,path , lvl) AS 
	(
	SELECT email ,connectedWith_email , email || '==>' || connectedWith_email , 1
	FROM public."Connects" 
	UNION
	SELECT p.email1,f.connectedWith_email,p.path || '==>' || f.connectedWith_email , p.lvl+1
	FROM MyView AS p JOIN public."Connects" AS f ON (p.email2 = f.email)
	WHERE POSITION(f.connectedWith_email IN p.path)=0);
SELECT * FROM MyView; 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Data Retrieval
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--1
CREATE OR REPLACE FUNCTION public."retrieval_1"(character varying) RETURNS TABLE(email varchar(30),firstName varchar(15),secondName varchar(20),thePassword varchar(15),subscriptionExpiry date,dateOfBirth date,country varchar(20),postalCode integer,gender genders,lastLoginDate date) AS
$BODY$
DECLARE t_school  varchar(30);
DECLARE t_fromYear integer;
DECLARE t_toYear integer;
begin
	SELECT public."Education".school,public."Education".fromYear,public."Education".toYear INTO t_school,t_fromYear,t_toYear FROM public."Education" WHERE public."Education".email = $1;
	RETURN QUERY 
	SELECT * FROM public."Member" WHERE public."Member".email 
	IN (SELECT public."Education".email FROM public."Education" 
	WHERE  public."Education".school=t_school AND public."Education".email NOT IN (SELECT public."myview".email2 FROM public."myview" WHERE public."myview".email1=$1) AND (public."Education".toYear <= t_toYear and public."Education".toYear >= t_fromYear) OR (public."Education".fromYear >= t_fromYear and public."Education".toYear <= t_toYear)) ; 
	
end;
$BODY$
LANGUAGE 'plpgsql' ;

--2
CREATE OR REPLACE FUNCTION public."retrieval_2"(character varying,INTEGER) RETURNS TABLE(email1 varchar(30),email2 varchar(30),path text,lvl integer) AS
$BODY$
begin 
	RETURN QUERY
	SELECT public."myview".email1 AS email1,public."myview".email2,public."myview".path,public."myview".lvl FROM public."myview" WHERE public."myview".email1=$1 AND public."myview".lvl = $2;
end;
$BODY$
LANGUAGE 'plpgsql' ;


--3
CREATE OR REPLACE FUNCTION public."retrieval_3"() RETURNS TABLE(email varchar(30),firstName varchar(15),secondName varchar(20),thePassword varchar(15),subscriptionExpiry date,dateOfBirth date,country varchar(20),postalCode integer,gender genders,lastLoginDate date) AS
$BODY$
begin
	RETURN QUERY
	SELECT * FROM public."Member" WHERE public."Member".email IN (SELECT public."Article".email FROM public."Article" GROUP BY public."Article".email HAVING COUNT(theText)>=2);
end;
$BODY$
LANGUAGE 'plpgsql' ;

--4
CREATE OR REPLACE FUNCTION public."retrieval_4"(character varying) RETURNS TABLE(email varchar(30),firstName varchar(15),secondName varchar(20),thePassword varchar(15),subscriptionExpiry date,dateOfBirth date,country varchar(20),postalCode integer,gender genders,lastLoginDate date) AS
$BODY$
begin 
	RETURN QUERY
	SELECT * FROM public."Member" WHERE public."Member".email 
	IN ( SELECT public."Article_Comment".email FROM public."Article_Comment" GROUP BY public."Article_Comment".email HAVING COUNT(DISTINCT articleID) =
	(SELECT COUNT(public."Article".email) FROM public."Article" WHERE public."Article".email= $1));
end;
$BODY$
LANGUAGE 'plpgsql' ;

--5
CREATE OR REPLACE FUNCTION public."retrieval_5"() RETURNS TABLE(articleID smallint,title varchar(40),categoryID integer,theText varchar(2000),datePosted date,email varchar(30),commentsNO bigint) AS
$BODY$
begin 
	RETURN QUERY
	SELECT public."Article".articleID,public."Article".title,public."Article".categoryID,public."Article".theText,public."Article".datePosted,public."Article".email,COUNT(public."Article_Comment".theComment) 
	FROM public."Article" LEFT JOIN public."Article_Comment" 
	ON public."Article".ArticleID = public."Article_Comment".ArticleId
	GROUP BY public."Article".articleID;
end;
$BODY$
LANGUAGE 'plpgsql' ;


--6
CREATE OR REPLACE FUNCTION public."retrieval_6"() RETURNS TABLE(email varchar(30),EduLever varchar(30)) AS
$BODY$
DECLARE cnt INTEGER;
begin 
	SELECT AVG (cnt1) into cnt FROM (
		SELECT 
			COUNT(public."Article_Comment".theComment) AS cnt1 FROM public."Article_Comment" GROUP BY public."Article_Comment".articleID
	) t;
	RETURN QUERY
	SELECT public."Education".email,public."Education".EduLevel from public."Education" WHERE public."Education".email IN (
	SELECT public."Article".email
	FROM public."Article" INNER JOIN public."Article_Comment" 
	ON public."Article".ArticleID = public."Article_Comment".ArticleId 
	GROUP BY public."Article".email
	HAVING COUNT(public."Article_Comment".theComment) > cnt);
end;
$BODY$
LANGUAGE 'plpgsql' ;

--7
CREATE OR REPLACE FUNCTION public."retrieval_7"() RETURNS TABLE(id1 smallint,id2 smallint) AS
$BODY$
begin 
	RETURN QUERY
	SELECT t1.advertismentID , t2.advertismentID 
	FROM 
	(SELECT public."Advertisment".advertismentID,jobType AS j1,Industry AS i1,Country AS c1,Salary::text::INT AS s1 FROM public."Job_Offer" INNER JOIN public."Advertisment" ON public."Job_Offer".advertismentID = public."Advertisment".advertismentID) t1 
	INNER JOIN 
	(SELECT public."Advertisment".advertismentID,jobType AS j2,Industry AS i2,Country AS c2,Salary::text::INT AS s2 FROM public."Job_Seek" INNER JOIN public."Advertisment" ON public."Job_Seek".advertismentID = public."Advertisment".advertismentID) t2 
	ON (j1 = j2) AND (i1 = i2) AND (c1 = c2 ) 
	WHERE s2 BETWEEN s1 - s1*(0.1) AND  s1 + s1*(0.1);
	
end;
$BODY$
LANGUAGE 'plpgsql' ;

	
--8
CREATE OR REPLACE FUNCTION public."retrieval_8"(character varying) RETURNS TABLE(email1 varchar(30),email2 varchar(30),path text,lvl integer) AS
$BODY$
begin 
	RETURN QUERY
	SELECT public."myview".email1 AS email1,public."myview".email2,public."myview".path,public."myview".lvl FROM public."myview" WHERE public."myview".email1=$1;
end;
$BODY$
LANGUAGE 'plpgsql' ;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Calculations
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--1 
CREATE OR REPLACE FUNCTION public."calc_1"() RETURNS TABLE(email varchar(30),cmnts bigint) AS
$BODY$
begin
	RETURN QUERY
	SELECT public."Member".email, COUNT(public."Article_Comment".theComment) FROM public."Article_Comment" RIGHT JOIN public."Member"
	ON public."Article_Comment".email =  public."Member".email
	GROUP BY public."Member".email; 
end;
$BODY$
LANGUAGE 'plpgsql' ;


--2 
CREATE OR REPLACE FUNCTION public."calc_2"() RETURNS INTEGER AS
$BODY$
begin
	RETURN 
	(SELECT AVG(salary::INTEGER) FROM public."Advertisment" INNER JOIN public."Job_Seek" ON public."Advertisment".advertismentID = public."Job_Seek".advertismentID WHERE specialWorkCapability = 'REMOTED_WORK');
end;
$BODY$
LANGUAGE 'plpgsql' ;


--3 
CREATE OR REPLACE FUNCTION public."calc_3"() RETURNS TABLE(Months double precision,cnt bigint) AS
$BODY$
begin
	RETURN QUERY 
	SELECT date_part('month',dateSent) AS M1, count(msgID) FROM public."Msg" GROUP BY M1 ORDER BY M1;
end;
$BODY$
LANGUAGE 'plpgsql' ;

--4 
CREATE OR REPLACE FUNCTION public."calc_4"() RETURNS INTEGER AS
$BODY$
begin
	RETURN 
	(SELECT AVG(public."Recommendation_Msg".dateSent - public."Recommendation_Request".dateSent)
	FROM public."Recommendation_Request" INNER JOIN public."Recommendation_Msg"
	ON public."Recommendation_Request".requestID = public."Recommendation_Msg".requestID 
	WHERE theStatus = 'REPLIED');
end;
$BODY$
LANGUAGE 'plpgsql' ;


--5 
CREATE OR REPLACE FUNCTION public."calc_5"() RETURNS TABLE(email varchar(30),cnt bigint) AS
$BODY$
begin
	RETURN QUERY 
	SELECT public."Recommendation_Msg".email, COUNT(public."Recommendation_Msg".email) maximum  
	FROM public."Recommendation_Msg" 	
	GROUP BY public."Recommendation_Msg".email
	ORDER BY maximum DESC LIMIT 1;
end;
$BODY$
LANGUAGE 'plpgsql' ;


--------------------------------------------------------------------------------------------------------------------------------
--INITIALISE
--------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public."Initialize"() RETURNS void AS
$BODY$
begin
--CATEGORIES
	INSERT INTO public."Category" VALUES (1, 'HIGH - EDUCATION'),
					     (2, 'BASIC - EDUCATION'),
				             (3, 'LOW - EDUCATION'),   
					     (4, 'BIOGRAPHY'),
					     (5,'INTEREST: PIANO'),
					     (6,'ARTICLE: LITERATURE'),
					     (7,'ARTICLE: ECONOMY'),
					     (8, 'QUESTION: ASTRONOMY');
--MEMBERS/EDUCATION/EXPERIENCE/SUMMARY
	--1
	INSERT INTO public."Member" VALUES ('test@domain.gr','MARKOS','MAUROTSOUKALOS','PASS123','2016-06-01','1995-02-14','GREECE',11146,'MALE','2016-04-01');
	INSERT INTO public."Experience" VALUES(1,'ANT1','PAST','ACTOR','ΣΤΟΝ ΡΟΛΟ ΤΟΥ ΓΙΟΥ',1995,2010,'test@domain.gr');
	INSERT INTO public."Education" VALUES(1,'GREECE','IONIOS','LUKEIO',1,1985,1994,'test@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Markos','REMOTED_WORK',4,'test@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(1,'MyAssociations','MyAwards','test@domain.gr');
	--2
	INSERT INTO public."Member" VALUES ('test1@domain.gr','MAKHS','KOTSAMPASHS','PASS123','2016-06-02','1995-02-14','GREECE',11146,'MALE','2016-04-02');
	INSERT INTO public."Experience" VALUES(2,'ANT1','CURRENT','ACTOR','ΣΤΟΝ ΡΟΛΟ ΤΟΥ ΑΔΕΛΦΙΚΟΥ ΦΙΛΟΥ',1995,2010,'test1@domain.gr');
	INSERT INTO public."Education" VALUES(2,'GREECE','IONIOS','LUKEIO',1,1984,1994,'test1@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Makhs','REMOTED_WORK',4,'test1@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(2,'MyAssociations','MyAwards','test1@domain.gr');
	--3
	INSERT INTO public."Member" VALUES ('test2@domain.gr','NIKOS','PAPPOULIAS','PASS123','2016-06-03','1995-02-14','GREECE',11146,'MALE','2016-04-03');
	INSERT INTO public."Experience" VALUES(3,'STAR','CURRENT','DIRECTOR','DIRECTOR OF TITANIC',1996,2020,'test2@domain.gr');
	INSERT INTO public."Education" VALUES(3,'GREECE','MORAITIS','LUKEIO',1,1986,1995,'test2@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Nikos','NONE',4,'test2@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(3,'MyAssociations','MyAwards','test2@domain.gr');
	--4
	INSERT INTO public."Member" VALUES ('test3@domain.gr','GIORGOS','KARAISKAKHS','PASS123','2016-06-04','1995-02-14','GREECE',11146,'MALE','2016-04-04');
	INSERT INTO public."Experience" VALUES(4,'MEGA','CURRENT','DIRECTOR','DIRECTOR OF CIRCLE',1996,2021,'test3@domain.gr');
	INSERT INTO public."Education" VALUES(4,'GREECE','ELLHNOGALLIKH','LUKEIO',1,1995,2010,'test3@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Giorgos','NONE',4,'test3@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(4,'MyAssociations','MyAwards','test3@domain.gr');
	--5
	INSERT INTO public."Member" VALUES ('test4@domain.gr','KOSTAS','THEOFANOUS','PASS123','2016-06-05','1995-02-14','GREECE',11146,'MALE','2016-04-05');
	INSERT INTO public."Experience" VALUES(5,'BSN','CURRENT','PROGRAMMER','COMMERCIAL UNIT SOFTWARE DEVELOPMENT',1996,2022,'test4@domain.gr');
	INSERT INTO public."Education" VALUES(5,'GREECE','MORAITIS','LUKEIO',1,1995,2010,'test4@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Kostas','NONE',4,'test4@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(5,'MyAssociations','MyAwards','test4@domain.gr');
	--6
	INSERT INTO public."Member" VALUES ('test5@domain.gr','MARIA','ZEBEKOGLOU','PASS123','2016-06-06','1995-02-14','GREECE',11146,'FEMALE','2016-04-06');
	INSERT INTO public."Experience" VALUES(6,'BSN','CURRENT','CEO','CEO OF THE COMPANY',1996,2020,'test5@domain.gr');
	INSERT INTO public."Education" VALUES(6,'GREECE','1o AMAROUSIOU','LUKEIO',1,1995,2010,'test5@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Maria','REMOTED_WORK',4,'test5@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(6,'MyAssociations','MyAwards','test5@domain.gr');
	--7
	INSERT INTO public."Member" VALUES ('test6@domain.gr','GEORGIA','PALIOURA','PASS123','2016-06-07','1995-02-14','GREECE',11146,'FEMALE','2016-04-07');
	INSERT INTO public."Experience" VALUES(7,'BSN','PAST','MARKETING','MARKETING OF PRODUCTS',1996,2013,'test6@domain.gr');
	INSERT INTO public."Education" VALUES(7,'GREECE','IONIOS','LUKEIO',1,1995,2010,'test6@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Georgia','NONE',4,'test6@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(7,'MyAssociations','MyAwards','test6@domain.gr');
	--8
	INSERT INTO public."Member" VALUES ('test7@domain.gr','MANOS','GERONIKOS','PASS123','2016-06-08','1995-02-14','GREECE',11146,'MALE','2016-04-08');
	INSERT INTO public."Experience" VALUES(8,'BSN','PAST','MARKETING','MARKETING OF PRODUCTS',1996,2014,'test7@domain.gr');
	INSERT INTO public."Education" VALUES(8,'GREECE','3o CHALANDRIOU','LUKEIO',1,1995,2010,'test7@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Manos','REMOTED_WORK',4,'test7@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(8,'MyAssociations','MyAwards','test7@domain.gr');
	--9
	INSERT INTO public."Member" VALUES ('test8@domain.gr','DHMHTRHS','KANAKHS','PASS123','2016-06-09','1995-02-14','GREECE',11146,'MALE','2016-04-09');
	INSERT INTO public."Experience" VALUES(9,'BSN','CURRENT','LAWER','LAWER DIVISION OF THE COMPANY',1996,2018,'test8@domain.gr');
	INSERT INTO public."Education" VALUES(9,'GREECE','1o AMAROUSIOU','GYMNASIO',2,1995,2010,'test8@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Dhmhtrhs','REMOTED_WORK',4,'test8@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(9,'MyAssociations','MyAwards','test8@domain.gr');
	--10
	INSERT INTO public."Member" VALUES ('test9@domain.gr','VASILIS','PERISTERIS','PASS123','2016-06-10','1995-02-14','GREECE',11146,'MALE','2016-04-10');
	INSERT INTO public."Experience" VALUES(10,'MEGA','CURRENT','CAMERAMAN','CAMERA HANDLER',1996,2019,'test9@domain.gr');
	INSERT INTO public."Education" VALUES(10,'GREECE','AVGOULEA','LUKEIO',1,1995,2010,'test9@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Vasilis','NONE',4,'test9@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(10,'MyAssociations','MyAwards','test9@domain.gr');
	--11
	INSERT INTO public."Member" VALUES ('test10@domain.gr','ZOI','ARVANITH','PASS123','2016-06-11','1995-02-14','GREECE',11146,'FEMALE','2016-04-11');
	INSERT INTO public."Experience" VALUES(11,'MEGA','PAST','MARKETING','MARKETING OF PRODUCTS',1996,2013,'test10@domain.gr');
	INSERT INTO public."Education" VALUES(11,'GREECE','AVGOULEA','LUKEIO',1,1995,2010,'test10@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Zoi','REMOTED_WORK',4,'test10@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(11,'MyAssociations','MyAwards','test10@domain.gr');
	--12
	INSERT INTO public."Member" VALUES ('test11@domain.gr','CHRISTINA','KARAKOSTA','PASS123','2016-06-12','1995-02-14','GREECE',11146,'FEMALE','2016-04-12');
	INSERT INTO public."Experience" VALUES(12,'BSN','CURRENT','TECHNICIAN','HARDWARE TECHNICIAN',1996,2035,'test11@domain.gr');
	INSERT INTO public."Education" VALUES(12,'GREECE','1o AMAROUSIOU','LUKEIO',1,1995,2010,'test11@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Christina','REMOTED_WORK',4,'test11@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(12,'MyAssociations','MyAwards','test11@domain.gr');
	--13
	INSERT INTO public."Member" VALUES ('test12@domain.gr','LIDIA','MANTA','PASS123','2016-06-13','1995-02-14','GREECE',11146,'FEMALE','2016-04-13');
	INSERT INTO public."Experience" VALUES(13,'SOFTONE','PAST','MARKETING','MARKETING OF PRODUCTS',1996,2001,'test12@domain.gr');
	INSERT INTO public."Education" VALUES(13,'GREECE','IONIOS','LUKEIO',1,1995,2010,'test12@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Lidia','NONE',4,'test12@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(13,'MyAssociations','MyAwards','test12@domain.gr');
	--14
	INSERT INTO public."Member" VALUES ('test13@domain.gr','KONSTANTINOS','MPOGDANOS','PASS123','2016-06-14','1995-02-14','GREECE',11146,'MALE','2016-04-14');
	INSERT INTO public."Experience" VALUES(14,'SKAITV','PAST','REPORTER','NEWS REPORTER',1996,2013,'test13@domain.gr');
	INSERT INTO public."Education" VALUES(14,'GREECE','AVGOULEA','LUKEIO',1,1995,2010,'test13@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Konstantinos','NONE',4,'test13@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(14,'MyAssociations','MyAwards','test13@domain.gr');
	--15
	INSERT INTO public."Member" VALUES ('test14@domain.gr','ANTONHS','PAPADHMHTRIOU','PASS123','2016-06-15','1995-02-14','GREECE',11146,'MALE','2016-04-15');
	INSERT INTO public."Experience" VALUES(15,'STAR','PAST','REPORTER','NEWS REPORTER',1996,2012,'test14@domain.gr');
	INSERT INTO public."Education" VALUES(15,'GREECE','3o CHALANDRIOU','DHMOTIKO',3,1995,2010,'test14@domain.gr');
	INSERT INTO public."Summary" VALUES('Hello!','Hello my name is Antonhs','NONE',4,'test14@domain.gr');
	INSERT INTO public."Additional_Info" VALUES(15,'MyAssociations','MyAwards','test14@domain.gr');
	
--CONNECTS
	INSERT INTO public."Connects" VALUES('test@domain.gr','test1@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test1@domain.gr','test@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test2@domain.gr','test3@domain.gr','FRIENDS','No Comment','2016-04-03'),
					    ('test3@domain.gr','test2@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test3@domain.gr','test4@domain.gr','FRIENDS','No Comment','2016-04-04'),
					    ('test4@domain.gr','test3@domain.gr','FRIENDS','No Comment','2016-04-02'),
				            ('test5@domain.gr','test6@domain.gr','FRIENDS','No Comment','2016-04-06'),
				            ('test6@domain.gr','test5@domain.gr','FRIENDS','No Comment','2016-04-02'),
				            ('test6@domain.gr','test7@domain.gr','FRIENDS','No Comment','2016-04-07'),
				            ('test7@domain.gr','test6@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test7@domain.gr','test8@domain.gr','FRIENDS','No Comment','2016-04-08'),
					    ('test8@domain.gr','test7@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test9@domain.gr','test10@domain.gr','FRIENDS','No Comment','2016-04-10'),
					    ('test10@domain.gr','test9@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test10@domain.gr','test11@domain.gr','FRIENDS','No Comment','2016-04-11'),
					    ('test11@domain.gr','test10@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test@domain.gr','test7@domain.gr','FRIENDS','No Comment','2016-04-07'),
					    ('test7@domain.gr','test@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test2@domain.gr','test6@domain.gr','FRIENDS','No Comment','2016-04-04'),
					    ('test6@domain.gr','test2@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test1@domain.gr','test2@domain.gr','FRIENDS','No Comment','2016-04-02'),
					    ('test2@domain.gr','test1@domain.gr','FRIENDS','No Comment','2016-04-02');


--ADVERTISMENTS/JOB_OFFERS/JOB_SEEKS
	INSERT INTO public."Advertisment" VALUES(1,'1000','ACTOR','NONE','LYKEIO','REMOTED_WORK','ACTOR FOR SERIES','ATHENS',11146,'GREECE','2016-04-09','test@domain.gr');
	INSERT INTO public."Job_Seek" VALUES(1,'Hello i want to become an actor'); 
	INSERT INTO public."Advertisment" VALUES(2,'900','ACTOR','NONE','LYKEIO','REMOTED_WORK','ACTOR FOR SERIES','ATHENS',11146,'GREECE','2016-04-09','test1@domain.gr');
	INSERT INTO public."Job_Offer" VALUES(2,'ACTOR FOR SERIES',18,50,'ANT1','ant1.gr'); 
	INSERT INTO public."Advertisment" VALUES(3,'1100','DIRECTOR','NONE','LYKEIO','REMOTED_WORK','DIRECTOR FOR SERIES','ATHENS',11146,'GREECE','2016-04-09','test2@domain.gr');
	INSERT INTO public."Job_Seek" VALUES(3,'Hello i want to become a director'); 

--ARTICLE/ARTICLE COMMENT
	INSERT INTO public."Article" VALUES(1,'The Alchemist- Review',6,'The Alchemist By Paulo Coelho','2016-04-03','test@domain.gr'),
					   (2,'DAVINCI CODE -Review',6,'DaVincis Code By Dan Brown','2016-04-04','test1@domain.gr'),
					   (3,'Future Economy',7,'Specs of the worlds future economy','2016-04-03','test4@domain.gr');
	INSERT INTO public."Article_Comment" VALUES(1,'MyComment For your Review','2016-03-04',1,'test2@domain.gr');

--QUESTIONS/ANSWERS
	INSERT INTO public."Question" VALUES(1,'Radius of the sun ? ','2016-06-06','test@domain.gr',8);
	INSERT INTO public."Answer" VALUES(1,'The radius of the Sun is about 700,000 km','2016-06-06',1,'test2@domain.gr');

--INTERESTS
	INSERT INTO public."Member_Interests" VALUES('test@domain.gr',5);

--MESSAGE
	INSERT INTO public."Msg" VALUES(1,'2016-04-04','Invite For Lecture','Dear Friend,I want to invite you to my lecture','test@domain.gr','test1@domain.gr');

--RECOMMENDATION_MSG/RECOMMENDATION_REQUEST
	INSERT INTO public."Recommendation_Request" VALUES(1,'2016-03-03','PENDING','test@domain.gr','test1@domain.gr','test2@domain.gr'),
							  (2,'2016-03-03','REPLIED','test1@domain.gr','test2@domain.gr','test3@domain.gr');
	INSERT INTO public."Recommendation_Msg" VALUES(1,'2016-03-03','Recommended Member','test1@domain.gr',2);
--INVITATION
	INSERT INTO public."Invitation" VALUES(1,'2016-03-03','PENDING','test@domain.gr','test14@domain.gr');
--ENDORSES
	INSERT INTO public."Endorses" VALUES('test@domain.gr','test12@domain.gr','Skills','2016-03-03');
end;
$BODY$
LANGUAGE 'plpgsql' ;