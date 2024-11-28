-- Задание №1
-- Контрольная работа. Чернова Алла ИАД-12
CREATE TABLE "AppUser" (
    "User ID" SERIAL PRIMARY KEY,
    "Username" VARCHAR(100) NOT NULL,
    "Email" VARCHAR(100) NOT NULL UNIQUE,
    "PasswordHash" VARCHAR(255) NOT NULL
);

CREATE TABLE "Channel" (
    "ChannelID" SERIAL PRIMARY KEY,
    "Title" VARCHAR(100) NOT NULL,
    "Description" TEXT,
    "AdminID" INT,
    FOREIGN KEY ("AdminID") REFERENCES "AppUser"("User ID")
);

CREATE TABLE "Message" (
    "MessageID" SERIAL PRIMARY KEY,
    "SenderID" INT, 
    "ChannelID" INT, -- NULL если сообщение отправлено личным сообщением
    "ReceiverID" INT, -- can be UserID or ChannelID depending on MessageType
    "MessageData" TEXT NOT NULL,
    "SentTime" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "MessageType" VARCHAR(10) CHECK ("MessageType" IN ('personal', 'channel')) NOT NULL,
    FOREIGN KEY ("SenderID") REFERENCES "AppUser"("User ID"),
    FOREIGN KEY ("ChannelID") REFERENCES "Channel"("ChannelID"),
    FOREIGN KEY ("ReceiverID") REFERENCES "AppUser"("User ID")
);

CREATE TABLE "File" (
    "FileID" SERIAL PRIMARY KEY,
    "User ID" INT,
    "MessageID" INT,
    "FileData" BYTEA NOT NULL,
    "Timestamp" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("User ID") REFERENCES "AppUser"("User ID"),
    FOREIGN KEY ("MessageID") REFERENCES "Message"("MessageID")
);

CREATE TABLE "Reaction" (
    "ReactionID" SERIAL PRIMARY KEY,
    "MessageID" INT,
    "User ID" INT,
    "Emoji" VARCHAR(10),
    FOREIGN KEY ("MessageID") REFERENCES "Message"("MessageID"),
    FOREIGN KEY ("User ID") REFERENCES "AppUser"("User ID")
);

CREATE TABLE "Subscription" (
    "SubscriptionID" SERIAL PRIMARY KEY,
    "User ID" INT,
    "ChannelID" INT,
    FOREIGN KEY ("User ID") REFERENCES "AppUser"("User ID"),
    FOREIGN KEY ("ChannelID") REFERENCES "Channel"("ChannelID")
);

CREATE TABLE "ForwardedMessage" (
    "ForwardedMessageID" SERIAL PRIMARY KEY,
    "OriginalMessageID" INT,
    "ForwardedByID" INT,
    "ForwardedToID" INT,
    "ForwardedTime" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("OriginalMessageID") REFERENCES "Message"("MessageID"),
    FOREIGN KEY ("ForwardedByID") REFERENCES "AppUser"("User ID"),
    FOREIGN KEY ("ForwardedToID") REFERENCES "AppUser"("User ID")
);

-- Задание №2
--  Напишите запрос на SQL к БД, спроектированной в задании 1, возвращающий 
--  количество личных сообщений с файлами, отправленных, полученных и пересланных 
--  указанным пользователем за указанный период времени. Результат: три числа.

SELECT 
    COUNT(CASE WHEN m."SenderID" = @User ID THEN 1 END) AS SentMessagesWithFiles,
    COUNT(CASE WHEN m."ReceiverID" = @User ID THEN 1 END) AS ReceivedMessagesWithFiles,
    COUNT(fm."ForwardedByID") AS ForwardedMessagesWithFiles
FROM 
    "Message" m
LEFT JOIN 
    "File" f ON m."MessageID" = f."MessageID"
LEFT JOIN 
    "ForwardedMessage" fm ON m."MessageID" = fm."OriginalMessageID"
WHERE 
    m."MessageType" = 'personal' 
    AND m."SentTime" BETWEEN @StartDate AND @EndDate --даты любые здесь
    AND f."FileID" IS NOT NULL;

-- Задание №3
-- Напишите запрос на SQL к БД, спроектированной в задании 1, возвращающий 
-- всех пользователей, у которых в сообщениях хотя бы одного канала, на который 
-- он подписан,  количество использований эмодзи превышает 5. 
-- Результат: список id пользователей.

SELECT 
    DISTINCT s."User ID"
FROM 
    "Subscription" s
JOIN 
    "Message" m ON s."ChannelID" = m."ChannelID"
JOIN 
    "Reaction" r ON m."MessageID" = r."MessageID"
GROUP BY 
    s."User ID", m."MessageID"
HAVING 
    COUNT(r."Emoji") > 5;

-- Задание №4
-- Напишите запрос на SQL к БД, спроектированной в задании 1, 
-- возвращающий  список из (не более, чем) 3 наиболее активных каналов 
-- по количеству отправленных в них сообщений и для каждого 
-- такого канала - одно сообщение, у которого максимальное количество эмодзи.  
-- Результат: список из строк (название канала, количество отправленных сообщений, 
-- id сообщения, самого популярного по количеству эмодзи ).

WITH ActiveChannels AS (
    SELECT 
        c."ChannelID",
        c."Title",
        COUNT(m."MessageID") AS MessageCount
    FROM 
        "Channel" c
    LEFT JOIN 
        "Message" m ON c."ChannelID" = m."ChannelID"
    GROUP BY 
        c."ChannelID", c."Title"
    ORDER BY 
        MessageCount DESC
    LIMIT 3
),
MaxEmojiMessages AS (
    SELECT 
        m."ChannelID",
        m."MessageID",
        COUNT(r."Emoji") AS EmojiCount
    FROM 
        "Message" m
    LEFT JOIN 
        "Reaction" r ON m."MessageID" = r."MessageID"
    GROUP BY 
        m."ChannelID", m."MessageID"
)

SELECT 
    ac."Title",
    ac.MessageCount,
    mem."MessageID"
FROM 
    ActiveChannels ac
JOIN 
    MaxEmojiMessages mem ON ac."ChannelID" = mem."ChannelID"
WHERE 
    mem."EmojiCount" = (SELECT MAX(EmojiCount) FROM MaxEmojiMessages WHERE "ChannelID" = ac."ChannelID");