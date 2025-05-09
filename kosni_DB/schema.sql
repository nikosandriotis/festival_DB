-- Use the kosni_db database
USE kosni_db;

-- Drop tables if they exist to avoid conflicts
SET
  FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Evaluation;
DROP TABLE IF EXISTS ResaleBuyerQueue;
DROP TABLE IF EXISTS ResaleTicket;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS StaffAssignment;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS ArtistGenre;
DROP TABLE IF EXISTS MusicGenre;
DROP TABLE IF EXISTS Performance;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Stage;
DROP TABLE IF EXISTS Festival;
DROP TABLE IF EXISTS Band_Member;
DROP TABLE IF EXISTS Band;
DROP TABLE IF EXISTS Artist;
DROP TABLE IF EXISTS Visitor;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS EntityImage;
DROP PROCEDURE IF EXISTS ProcessResaleQueue;

SET
  FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Location (
  Location_ID INT PRIMARY KEY AUTO_INCREMENT,
  Address VARCHAR(255) NOT NULL,
  Coordinates VARCHAR(100),
  City VARCHAR(100) NOT NULL,
  Country VARCHAR(100) NOT NULL,
  Continent VARCHAR(100),
  Image TEXT,
  Image_Description TEXT
);

CREATE TABLE Festival (
  Festival_ID INT PRIMARY KEY AUTO_INCREMENT,
  Year YEAR NOT NULL,
  Start_Date DATE NOT NULL,
  End_Date DATE NOT NULL,
  Image TEXT,
  Image_Description TEXT,
  Location_ID INT NOT NULL,
  Status ENUM('Scheduled', 'Ongoing', 'Completed') NOT NULL DEFAULT 'Scheduled',
  FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID),
  CHECK (End_Date > Start_Date),
  CHECK (Status != 'Canceled')
);

CREATE TABLE Stage (
  Stage_ID INT PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(100) NOT NULL,
  Description TEXT,
  Max_Capacity INT NOT NULL CHECK (Max_Capacity > 0),
  Technical_Equipment TEXT,
  Image TEXT,
  Image_Description TEXT
);

CREATE TABLE Event (
  Event_ID INT PRIMARY KEY AUTO_INCREMENT,
  Festival_ID INT NOT NULL,
  Stage_ID INT NOT NULL,
  Start_Time DATETIME NOT NULL,
  End_Time DATETIME NOT NULL,
  Status ENUM('Scheduled', 'Ongoing', 'Completed') NOT NULL DEFAULT 'Scheduled',
  FOREIGN KEY (Festival_ID) REFERENCES Festival(Festival_ID),
  FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID),
  CHECK (End_Time > Start_Time),
  CHECK (Status != 'Canceled'),
  UNIQUE (Stage_ID, Start_Time)
);

CREATE TABLE Artist(
  Artist_ID INT PRIMARY KEY AUTO_INCREMENT,
  Real_Name VARCHAR(100) NOT NULL,
  Stage_Name VARCHAR(100),
  Birthdate DATE,
  Website VARCHAR(255),
  Instagram_Profile VARCHAR(255),
  Image TEXT,
  Image_Description TEXT
);

CREATE TABLE Band (
  Band_ID INT PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(100) NOT NULL,
  Formation_Date DATE,
  Website VARCHAR(255),
  Instagram_Profile VARCHAR(255)
);

CREATE TABLE Band_Member (
  Band_ID INT NOT NULL,
  Artist_ID INT NOT NULL,
  PRIMARY KEY (Band_ID, Artist_ID),
  FOREIGN KEY (Band_ID) REFERENCES Band(Band_ID),
  FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID)
);

CREATE TABLE Performance (
  Performance_ID INT PRIMARY KEY AUTO_INCREMENT,
  Event_ID INT NOT NULL,
  Artist_ID INT,
  Band_ID INT,
  Type ENUM('Warm Up', 'Headline', 'Special Guest') NOT NULL,
  Start_Time DATETIME NOT NULL,
  Duration INT NOT NULL CHECK (
    Duration > 0
    AND Duration <= 180
  ),
  FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID),
  FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
  FOREIGN KEY (Band_ID) REFERENCES Band(Band_ID),
  CHECK (
    (
      Artist_ID IS NOT NULL
      AND Band_ID IS NULL
    )
    OR (
      Artist_ID IS NULL
      AND Band_ID IS NOT NULL
    )
  )
);

CREATE TABLE MusicGenre(
  Genre_ID INT PRIMARY KEY,
  Name TEXT,
  Subgenre TEXT
);

CREATE TABLE ArtistGenre(
  Artist_ID INT,
  Genre_ID INT,
  PRIMARY KEY (Artist_ID, Genre_ID),
  FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
  FOREIGN KEY (Genre_ID) REFERENCES MusicGenre(Genre_ID)
);

CREATE TABLE Staff (
  Staff_ID INT PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(100) NOT NULL,
  Age INT NOT NULL CHECK (Age >= 18),
  Role ENUM('Technical', 'Security', 'Auxiliary') NOT NULL,
  Experience_Level ENUM(
    'Intern',
    'Beginner',
    'Intermediate',
    'Experienced',
    'Expert'
  ) NOT NULL
);

CREATE TABLE StaffAssignment (
  Staff_ID INT NOT NULL,
  Event_ID INT NOT NULL,
  PRIMARY KEY (Staff_ID, Event_ID),
  FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID),
  FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID)
);

CREATE TABLE Visitor (
  Visitor_ID INT PRIMARY KEY AUTO_INCREMENT,
  First_Name VARCHAR(100) NOT NULL,
  Last_Name VARCHAR(100) NOT NULL,
  Contact_Info VARCHAR(255) NOT NULL,
  Age INT NOT NULL CHECK (Age >= 0)
);

CREATE TABLE Ticket (
  Ticket_ID INT PRIMARY KEY AUTO_INCREMENT,
  Performance_ID INT NOT NULL,
  Visitor_ID INT NOT NULL,
  Category ENUM('General', 'VIP', 'Backstage') NOT NULL,
  Purchase_Date DATE NOT NULL,
  Cost DECIMAL(10, 2) NOT NULL,
  Payment_Method ENUM('Credit Card', 'Debit Card', 'Bank Transfer') NOT NULL,
  EAN131_Code BIGINT NOT NULL UNIQUE,
  Activated BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID),
  FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
  UNIQUE (Visitor_ID, Performance_ID, Purchase_Date)
);

CREATE TABLE Evaluation (
  Evaluation_ID INT PRIMARY KEY AUTO_INCREMENT,
  Visitor_ID INT NOT NULL,
  Performance_ID INT NOT NULL,
  Evaluation_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Artist_Performance TINYINT NOT NULL CHECK (
    Artist_Performance BETWEEN 1 AND 3
  ),
  Sound_Lighting TINYINT NOT NULL CHECK (
    Sound_Lighting BETWEEN 1 AND 3
  ),
  Stage_Presence TINYINT NOT NULL CHECK (
    Stage_Presence BETWEEN 1 AND 3
  ),
  Organization TINYINT NOT NULL CHECK (
    Organization BETWEEN 1 AND 3
  ),
  Overall_Impression TINYINT NOT NULL CHECK (
    Overall_Impression BETWEEN 1 AND 3
  ),
  FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
  FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID),
  UNIQUE (Visitor_ID, Performance_ID)
);

CREATE TABLE ResaleTicket (
  ResaleTicket_ID INT PRIMARY KEY AUTO_INCREMENT,
  Ticket_ID INT NOT NULL UNIQUE,
  Seller_ID INT NOT NULL,
  Listed_At DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Status ENUM('Available', 'Sold', 'Withdrawn') NOT NULL DEFAULT 'Available',
  FOREIGN KEY (Ticket_ID) REFERENCES Ticket(Ticket_ID),
  FOREIGN KEY (Seller_ID) REFERENCES Visitor(Visitor_ID)
);

CREATE TABLE ResaleBuyerQueue (
  Queue_ID INT PRIMARY KEY AUTO_INCREMENT,
  Buyer_ID INT NOT NULL,
  Performance_ID INT NOT NULL,
  Category ENUM('General', 'VIP', 'Backstage') NOT NULL,
  Requested_At DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Status ENUM('Waiting', 'Matched', 'Cancelled') NOT NULL DEFAULT 'Waiting',
  FOREIGN KEY (Buyer_ID) REFERENCES Visitor(Visitor_ID),
  FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID)
);

-- DROP TABLE IF EXISTS TicketResaleQueue;
-- CREATE TABLE TicketResaleQueue(
--   Queue_ID INT PRIMARY KEY,
--   Ticket_ID INT,
--   Queue_Type TEXT,
--   Queue_Timestamp DATETIME,
--   FOREIGN KEY (Ticket_ID) REFERENCES Ticket(Ticket_ID)
-- );
CREATE TABLE EntityImage (
  Image_ID INT PRIMARY KEY AUTO_INCREMENT,
  Entity_Type ENUM(
    'Festival',
    'Artist',
    'Band',
    'Stage',
    'Equipment'
  ) NOT NULL,
  Entity_ID INT NOT NULL,
  Image_Description VARCHAR(255),
  Image_Data LONGBLOB NOT NULL
);

CREATE INDEX idx_ticket_performance ON Ticket (Performance_ID);
CREATE INDEX idx_ticket_visitor ON Ticket (Visitor_ID);
CREATE INDEX idx_event_festival ON Event (Festival_ID);
CREATE INDEX idx_event_stage ON Event (Stage_ID);
CREATE INDEX idx_staffassignment_staff ON StaffAssignment (Staff_ID);
CREATE INDEX idx_staffassignment_event ON StaffAssignment (Event_ID);
CREATE INDEX idx_performance_artist ON Performance (Artist_ID);
CREATE INDEX idx_performance_band ON Performance (Band_ID);
CREATE INDEX idx_performance_event ON Performance (Event_ID);
CREATE INDEX idx_evaluation_visitor ON Evaluation (Visitor_ID);
CREATE INDEX idx_evaluation_performance ON Evaluation (Performance_ID);
CREATE INDEX idx_resaleticket_ticket ON ResaleTicket (Ticket_ID);
CREATE INDEX idx_resaleticket_seller ON ResaleTicket (Seller_ID);
CREATE INDEX idx_resalebuyerqueue_buyer ON ResaleBuyerQueue (Buyer_ID);
CREATE INDEX idx_resalebuyerqueue_performance ON ResaleBuyerQueue (Performance_ID);

DELIMITER $$

-- ✅ Prevent overlapping events on the same stage within the same festival
CREATE TRIGGER prevent_event_overlap
BEFORE INSERT ON Event
FOR EACH ROW
BEGIN
  DECLARE overlap_count INT;

  SELECT COUNT(*) INTO overlap_count
  FROM Event
  WHERE Stage_ID = NEW.Stage_ID
    AND Festival_ID = NEW.Festival_ID
    AND DATE(Start_Time) = DATE(NEW.Start_Time)
    AND (
      NEW.Start_Time < End_Time AND
      NEW.End_Time > Start_Time
    );

  IF overlap_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Overlapping event detected on the same stage.';
  END IF;
END$$

-- ✅ Same as above, but for updates
CREATE TRIGGER prevent_event_overlap_update
BEFORE UPDATE ON Event
FOR EACH ROW
BEGIN
  DECLARE overlap_count INT;

  SELECT COUNT(*) INTO overlap_count
  FROM Event
  WHERE Stage_ID = NEW.Stage_ID
    AND Festival_ID = NEW.Festival_ID
    AND Event_ID != NEW.Event_ID
    AND (
      NEW.Start_Time < End_Time AND
      NEW.End_Time > Start_Time
    );

  IF overlap_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Overlapping event detected on the same stage.';
  END IF;
END$$

-- ✅ Enforce a break between sequential performances within an event
CREATE TRIGGER check_performance_break
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE previous_end_time DATETIME;
  DECLARE break_duration INT;
  DECLARE conflicting_count INT;

   -- Check if new performance overlaps with an existing one in the same event
  SELECT COUNT(*) INTO conflicting_count
  FROM Performance
  WHERE Event_ID = NEW.Event_ID
    AND DATE(Start_Time) = DATE(NEW.Start_Time)
    AND (
      -- Overlapping start or end time
      (NEW.Start_Time BETWEEN Start_Time AND (Start_Time + INTERVAL Duration MINUTE - INTERVAL 1 SECOND))
      OR ((NEW.Start_Time + INTERVAL NEW.Duration MINUTE - INTERVAL 1 SECOND) BETWEEN Start_Time AND (Start_Time + INTERVAL Duration MINUTE - INTERVAL 1 SECOND))
      OR (Start_Time BETWEEN NEW.Start_Time AND (NEW.Start_Time + INTERVAL NEW.Duration MINUTE - INTERVAL 1 SECOND))
    );

  IF conflicting_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Performance time overlaps with an existing performance.';
  END IF;

  SELECT MAX(Start_Time + INTERVAL Duration MINUTE) INTO previous_end_time
  FROM Performance
  WHERE Event_ID = NEW.Event_ID
    AND Start_Time < NEW.Start_Time
    AND DATE(Start_Time) = DATE(NEW.Start_Time);  -- ✅ Only same-day performances

  IF previous_end_time IS NOT NULL THEN
    SET break_duration = TIMESTAMPDIFF(MINUTE, previous_end_time, NEW.Start_Time);
    
    IF break_duration < 5 OR break_duration > 30 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes.';
    END IF;
  END IF;
END$$

-- ✅ Prevent artist overlap within the same festival
CREATE TRIGGER prevent_artist_overlap
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE overlap_count INT;
  DECLARE festival_id INT;

  IF NEW.Artist_ID IS NOT NULL THEN
    SELECT e.Festival_ID INTO festival_id
    FROM Event e
    WHERE e.Event_ID = NEW.Event_ID;

    SELECT COUNT(*) INTO overlap_count
    FROM Performance p
    JOIN Event e ON p.Event_ID = e.Event_ID
    WHERE p.Artist_ID = NEW.Artist_ID
      AND e.Festival_ID = festival_id
      AND (
        NEW.Start_Time < ADDTIME(p.Start_Time, SEC_TO_TIME(p.Duration * 60)) AND
        ADDTIME(NEW.Start_Time, SEC_TO_TIME(NEW.Duration * 60)) > p.Start_Time
      );

    IF overlap_count > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Artist has overlapping performance in the same festival.';
    END IF;
  END IF;
END$$

-- ✅ Prevent band overlap within the same festival
CREATE TRIGGER prevent_band_overlap
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE overlap_count INT;
  DECLARE festival_id INT;

  IF NEW.Band_ID IS NOT NULL THEN
    SELECT e.Festival_ID INTO festival_id
    FROM Event e
    WHERE e.Event_ID = NEW.Event_ID;

    SELECT COUNT(*) INTO overlap_count
    FROM Performance p
    JOIN Event e ON p.Event_ID = e.Event_ID
    WHERE p.Band_ID = NEW.Band_ID
      AND e.Festival_ID = festival_id
      AND (
        NEW.Start_Time < ADDTIME(p.Start_Time, SEC_TO_TIME(p.Duration * 60)) AND
        ADDTIME(NEW.Start_Time, SEC_TO_TIME(NEW.Duration * 60)) > p.Start_Time
      );

    IF overlap_count > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Band has overlapping performance in the same festival.';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_artist_consecutive_years
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE year INT;
  DECLARE consecutive_years INT;

  IF NEW.Artist_ID IS NOT NULL THEN
    -- Get the festival year of the new performance
    SELECT f.Year INTO year
    FROM Event e
    JOIN Festival f ON e.Festival_ID = f.Festival_ID
    WHERE e.Event_ID = NEW.Event_ID;

    -- Count distinct years in the sliding 3-year window
    SELECT COUNT(DISTINCT f.Year) INTO consecutive_years
    FROM Performance p
    JOIN Event e ON p.Event_ID = e.Event_ID
    JOIN Festival f ON e.Festival_ID = f.Festival_ID
    WHERE p.Artist_ID = NEW.Artist_ID
      AND f.Year BETWEEN year - 2 AND year;

    IF consecutive_years > 3 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Artist cannot perform more than 3 consecutive years.';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_band_consecutive_years
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE current_year INT;
  DECLARE consecutive_years INT;

  IF NEW.Band_ID IS NOT NULL THEN
    -- Get the festival year of the new performance
    SELECT f.Year INTO current_year
    FROM Event e
    JOIN Festival f ON e.Festival_ID = f.Festival_ID
    WHERE e.Event_ID = NEW.Event_ID;

    -- Count how many of the past 3 years the band has performed
    SELECT COUNT(DISTINCT f.Year) INTO consecutive_years
    FROM Performance p
    JOIN Event e ON p.Event_ID = e.Event_ID
    JOIN Festival f ON e.Festival_ID = f.Festival_ID
    WHERE p.Band_ID = NEW.Band_ID
      AND f.Year BETWEEN current_year - 2 AND current_year;

    IF consecutive_years >= 3 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Band cannot perform more than 3 consecutive years.';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

-- ✅ Ensure stage capacity is not exceeded
CREATE TRIGGER check_stage_capacity
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
  DECLARE total_tickets INT;
  DECLARE stage_capacity INT;

  SELECT COUNT(*) INTO total_tickets
  FROM Ticket
  WHERE Performance_ID = NEW.Performance_ID;

  SELECT s.Max_Capacity INTO stage_capacity
  FROM Performance p
  JOIN Event e ON p.Event_ID = e.Event_ID
  JOIN Stage s ON e.Stage_ID = s.Stage_ID
  WHERE p.Performance_ID = NEW.Performance_ID;

  IF total_tickets >= stage_capacity THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot sell ticket: stage capacity exceeded.';
  END IF;
END$$

-- ✅ Enforce VIP ticket limit to 10% of stage capacity
CREATE TRIGGER check_vip_limit
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
  DECLARE vip_tickets INT;
  DECLARE stage_capacity INT;
  DECLARE max_vip_tickets INT;

  IF NEW.Category = 'VIP' THEN
    SELECT COUNT(*) INTO vip_tickets
    FROM Ticket
    WHERE Performance_ID = NEW.Performance_ID
      AND Category = 'VIP';

    SELECT s.Max_Capacity INTO stage_capacity
    FROM Performance p
    JOIN Event e ON p.Event_ID = e.Event_ID
    JOIN Stage s ON e.Stage_ID = s.Stage_ID
    WHERE p.Performance_ID = NEW.Performance_ID;

    SET max_vip_tickets = FLOOR(stage_capacity * 0.10);

    IF vip_tickets >= max_vip_tickets THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot sell VIP ticket: VIP limit exceeded.';
    END IF;
  END IF;
END$$

DELIMITER ; 

DELIMITER $$

CREATE TRIGGER check_evaluation_ticket_activation
BEFORE INSERT ON Evaluation
FOR EACH ROW
BEGIN
  DECLARE ticket_count INT;

  SELECT COUNT(*) INTO ticket_count
  FROM Ticket t
  JOIN Performance p ON t.Performance_ID = p.Performance_ID
  WHERE t.Visitor_ID = NEW.Visitor_ID
    AND t.Performance_ID = NEW.Performance_ID
    AND t.Activated = 1;

  IF ticket_count = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Evaluation not allowed: visitor must have an activated ticket for the performance.';
  END IF;
END$$

DELIMITER ;

DELIMITER $$

-- ✅ Automatically match resale tickets with buyers (FIFO)
CREATE PROCEDURE ProcessResaleQueue()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE resale_ticket_id INT;
  DECLARE ticket_id INT;
  DECLARE performance_id INT;
  DECLARE category ENUM('General', 'VIP', 'Backstage');
  DECLARE buyer_id INT;
  DECLARE buyer_queue_id INT;

  -- Cursor for available resale tickets (FIFO)
  DECLARE resale_cursor CURSOR FOR
    SELECT rt.ResaleTicket_ID, t.Ticket_ID, p.Performance_ID, t.Category
    FROM ResaleTicket rt
    JOIN Ticket t ON rt.Ticket_ID = t.Ticket_ID
    JOIN Performance p ON t.Performance_ID = p.Performance_ID
    WHERE rt.Status = 'Available'
    ORDER BY rt.Listed_At ASC;

  -- Handle end of cursor
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN resale_cursor;

  read_loop: LOOP
    FETCH resale_cursor INTO resale_ticket_id, ticket_id, performance_id, category;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Match first waiting buyer for same performance and category
    SELECT rbq.Queue_ID, rbq.Buyer_ID
    INTO buyer_queue_id, buyer_id
    FROM ResaleBuyerQueue rbq
    WHERE rbq.Status = 'Waiting'
      AND rbq.Performance_ID = performance_id
      AND rbq.Category = category
    ORDER BY rbq.Requested_At ASC
    LIMIT 1;

    -- Process match if buyer found
    IF buyer_id IS NOT NULL THEN
      UPDATE Ticket
      SET Visitor_ID = buyer_id
      WHERE Ticket_ID = ticket_id;

      UPDATE ResaleTicket
      SET Status = 'Sold'
      WHERE ResaleTicket_ID = resale_ticket_id;

      UPDATE ResaleBuyerQueue
      SET Status = 'Matched'
      WHERE Queue_ID = buyer_queue_id;

      SET buyer_id = NULL;
    END IF;
  END LOOP;

  CLOSE resale_cursor;
END$$

DELIMITER ;
