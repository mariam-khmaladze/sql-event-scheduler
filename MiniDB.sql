DROP TABLE IF EXISTS EVENT;
DROP TABLE IF EXISTS OFFICIAL;
DROP TABLE IF EXISTS SPORT;

CREATE TABLE SPORT
(
	SPORTID SERIAL PRIMARY KEY,
	SPORTNAME VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO SPORT (SPORTNAME) VALUES ('Archery');		-- 1
INSERT INTO SPORT (SPORTNAME) VALUES ('Athletics');		-- 2
INSERT INTO SPORT (SPORTNAME) VALUES ('Badminton');		-- 3
INSERT INTO SPORT (SPORTNAME) VALUES ('Basketball');	     -- 4
INSERT INTO SPORT (SPORTNAME) VALUES ('Boxing');		-- 5
INSERT INTO SPORT (SPORTNAME) VALUES ('Diving');		-- 6
INSERT INTO SPORT (SPORTNAME) VALUES ('Fencing');		-- 7
INSERT INTO SPORT (SPORTNAME) VALUES ('Golf');			-- 8
INSERT INTO SPORT (SPORTNAME) VALUES ('Handball');		-- 9
INSERT INTO SPORT (SPORTNAME) VALUES ('Hockey');		-- 10
INSERT INTO SPORT (SPORTNAME) VALUES ('Ice Hockey');	     -- 11
INSERT INTO SPORT (SPORTNAME) VALUES ('Judo');			-- 12
INSERT INTO SPORT (SPORTNAME) VALUES ('Karate');		-- 13
INSERT INTO SPORT (SPORTNAME) VALUES ('Luge');			-- 14
INSERT INTO SPORT (SPORTNAME) VALUES ('Rowing');		-- 15
INSERT INTO SPORT (SPORTNAME) VALUES ('Rugby');			-- 16
INSERT INTO SPORT (SPORTNAME) VALUES ('Sailing');		-- 17
INSERT INTO SPORT (SPORTNAME) VALUES ('Shooting');		-- 18
INSERT INTO SPORT (SPORTNAME) VALUES ('Snowboard');		-- 19
INSERT INTO SPORT (SPORTNAME) VALUES ('Weightlifting');	-- 20

CREATE TABLE OFFICIAL
(
	OFFICIALID SERIAL PRIMARY KEY,
	USERNAME VARCHAR(20) NOT NULL UNIQUE,
	FIRSTNAME VARCHAR(50) NOT NULL, 
	LASTNAME VARCHAR(50) NOT NULL,
	PASSWORD VARCHAR(20) NOT NULL
);

INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('-','Not','Assigned','000');			-- 1
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('JohnW','John','Waith','999');			-- 2
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('ChrisP','Christopher','Putin','888');	-- 3
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('GuoZ','Guo','Zhang','777');			-- 4
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('JulieA','Julie','Ahlering','666');		-- 5
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('MaksimS','Maksim','Sulejmani','555');	-- 6
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('KrisN','Kristina','Ness','444');		-- 7
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('ZvonkoO','Zvonko','Ocic','333');		-- 8
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('SusanF','Susan','Fischer','222');		-- 9
INSERT INTO OFFICIAL (USERNAME,FIRSTNAME,LASTNAME,PASSWORD) VALUES ('KevinB','Kevin','Boyd','111');			-- 10

CREATE TABLE EVENT
(
	EVENTID SERIAL PRIMARY KEY,
	EVENTNAME VARCHAR(50) NOT NULL,
	SPORTID INTEGER REFERENCES SPORT,
	REFEREE INTEGER REFERENCES OFFICIAL,
	JUDGE INTEGER REFERENCES OFFICIAL,
	MEDALGIVER INTEGER REFERENCES OFFICIAL

);

INSERT INTO EVENT (EVENTNAME,SPORTID,REFEREE,JUDGE,MEDALGIVER) VALUES ('Men''s Singles Semifinal',3,2,3,4);		-- 1
INSERT INTO EVENT (EVENTNAME,SPORTID,REFEREE,JUDGE,MEDALGIVER) VALUES ('Women''s Long Jump Final',2,1,5,6);		-- 2
INSERT INTO EVENT (EVENTNAME,SPORTID,REFEREE,JUDGE,MEDALGIVER) VALUES ('Men''s Team Semifinal',1,3,4,5);		-- 3
INSERT INTO EVENT (EVENTNAME,SPORTID,REFEREE,JUDGE,MEDALGIVER) VALUES ('Men''s Tournament Semifinal',4,1,2,6);	-- 4
INSERT INTO EVENT (EVENTNAME,SPORTID,REFEREE,JUDGE,MEDALGIVER) VALUES ('Women''s Lightweight Final',5,4,6,1);	-- 5

CREATE OR REPLACE FUNCTION checkUserCredentials(myUser VARCHAR(20), pass VARCHAR(20))
    RETURNS TABLE
            (
                officialId    INTEGER,
                username      VARCHAR(20),
                firstName     VARCHAR(50),
                lastName      VARCHAR(50),
                password      VARCHAR(20)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT o.officialId, o.username, o.firstName, o.lastName, o.password
        FROM official o
        WHERE o.username = myUser
	      AND o.password = pass;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION findEventsByOfficial(refId INTEGER)
    RETURNS TABLE
            (
                eventId    INTEGER,
                eventName  VARCHAR(50),
                sportname  VARCHAR(100),
                referee    VARCHAR(20),
                judge      VARCHAR(20),
                medalGiver VARCHAR(20)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT e.eventId, e.eventName, s.sportname, r.username, j.username, m.username
        FROM event e
                 JOIN sport s ON e.sportid = s.sportid
                 JOIN official r ON e.referee = r.officialid
                 JOIN official j ON e.judge = j.officialid
                 JOIN official m ON e.medalgiver = m.officialid
        WHERE e.judge = refId
           OR e.referee = refId
           OR e.medalGiver = refId
	ORDER BY s.sportname;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION findEventsByCriteria(searchString VARCHAR(100))
    RETURNS TABLE
            (
                eventId    INTEGER,
                eventName  VARCHAR(50),
                sportname  VARCHAR(100),
                referee    VARCHAR(20),
                judge      VARCHAR(20),
                medalGiver VARCHAR(20)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT e.eventId, e.eventName, s.sportname, r.username, j.username, m.username
        FROM event e
                 JOIN sport s ON e.sportid = s.sportid
                 JOIN official r ON e.referee = r.officialid
                 JOIN official j ON e.judge = j.officialid
                 JOIN official m ON e.medalgiver = m.officialid
        WHERE s.sportname ILIKE CONCAT('%', searchString, '%')
           OR e.eventname ILIKE CONCAT('%', searchString, '%')
           OR r.username ILIKE CONCAT('%', searchString, '%')
           OR j.username ILIKE CONCAT('%', searchString, '%')
           OR m.username ILIKE CONCAT('%', searchString, '%')
	ORDER BY s.sportname;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION addEvent
				(    
					event_name  VARCHAR(50), 
				     sportId	 INTEGER,
				     refId	 INTEGER,
				     judgeId	 INTEGER,
				     medalId  INTEGER
				)
RETURNS void
AS
$$
BEGIN
    INSERT INTO Event (eventName, sportId, referee, judge, medalgiver)
	VALUES (event_name, sportId, refId, judgeId, medalId);
END;$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION updateEvent
				(    
				     event_id	 INTEGER,
				     event_name  VARCHAR(50), 
				 	 sport_id	 INTEGER,
				     refId		 INTEGER,
				     judgeId	 INTEGER,
				     medalId	 INTEGER
				)
RETURNS void
AS
$$
BEGIN
    UPDATE Event
    SET eventName = event_name,	sportId = sport_id, referee = refId, judge = judgeId, medalGiver = medalId
    WHERE eventId = event_id;
END;
$$ LANGUAGE plpgsql;
COMMIT;