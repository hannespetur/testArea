.mode colum
.headers on
.print '1. Find those teams which won their matches by at least 3 goals.'
SELECT homeID AS winnerID
FROM Matches
WHERE homeGoals-awayGoals>=3
	UNION
SELECT awayID AS winnerID
FROM Matches
WHERE awayGoals-homeGoals>=3;
.print ' '
.print '2. Find those teams which scored a goal after full-time (which is 90 minutes).'
SELECT DISTINCT teamID
FROM Goals
WHERE minute>90;
.print ' '
.print '3. Find the names of those countries with a space in their names (e.g. South Korea)'
.width 25
SELECT name
FROM Teams
WHERE name LIKE '% %';
.width 10
.print ' '
.print '4. Find the names of those teams which played in group A.'
SELECT name
FROM Teams
WHERE groupID=(
	SELECT id
	FROM Groups
	WHERE name='A'
);
.print ' '
.print '5. Find those players and their teams, who scored a goal for a team playing in group B.'
SELECT DISTINCT name,player
FROM Teams,Goals
WHERE teamID=code AND groupID=(
	SELECT id
	FROM Groups
	WHERE name='B'
);
.print ' '
.print '6. Find those teams which scored an equal amount of goals as a home team in different games.'
SELECT DISTINCT M1.homeID,M2.homeID
FROM Matches AS M1, Matches AS M2 ON M1.homeGoals=M2.homeGoals
WHERE M1.id<>M2.id AND M1.homeID<>M2.homeID;
.print ' '
.print '7. Find those players who scored two or more goals in a single game, and the games in which this happened.'
SELECT player,matchID
FROM Goals
GROUP BY matchID,player
HAVING count(*)>=2;
.print ' '
.print '8. Find the player, team, and minute for each goal scored in a match between Swiss and France (SUI and FRA).'
SELECT player,teamID,minute
FROM Goals
WHERE matchid=(
	SELECT id
	FROM Matches
	WHERE (homeID='SUI' AND awayID='FRA') OR (homeID='FRA' AND awayID='SUI')
);
.print ' '
.print '9. Find the minute where the most goals were scored.'
SELECT minute
FROM Goals
GROUP BY minute
HAVING count(*)=(
	SELECT max(goalsScored)
	FROM (
		SELECT count(*) AS goalsScored
		FROM Goals
		GROUP BY minute
	)
);
.print ' '
.print '10. Find the player in the German team (GER) with the most goals.'
SELECT player,count(*)
FROM Goals
WHERE teamID='GER'
GROUP BY player
HAVING count(*)=(
	SELECT max(goalsScored)
	FROM (
		SELECT count(*) AS goalsScored
		FROM Goals
		WHERE teamID='GER'
		GROUP BY player
	)
);
.print ' '
.print '11. Find the highest scoring player for each team, and how many goals he scored.'
SELECT player,teamID,max(goalsScored)
FROM (
	SELECT teamID,player,count(*) AS goalsScored
	FROM Goals
	GROUP BY teamID,player
	)
GROUP BY teamID;
.print ' '
.print '12. Find the team which won the most matches.'
SELECT Winner,sum(Wins) AS totalWins
FROM (
	SELECT homeID AS Winner,count(*) AS Wins,1 AS atHome
	FROM Matches
	WHERE homeGoals>awayGoals
	GROUP BY Winner
		UNION
	SELECT awayID AS Winner,count(*) AS Wins,0 AS atHome
	FROM Matches
	WHERE awayGoals>homeGoals
	GROUP BY Winner
)
GROUP BY Winner
HAVING totalWins=(
	SELECT max(totalWins)
	FROM (
		SELECT Winner,sum(Wins) AS totalWins
		FROM (
			SELECT homeID AS Winner,count(*) AS Wins,1 AS atHome
			FROM Matches
			WHERE homeGoals>awayGoals
			GROUP BY Winner
				UNION
			SELECT awayID AS Winner,count(*) AS Wins,0 AS atHome
			FROM Matches
			WHERE awayGoals>homeGoals
			GROUP BY Winner
			)
		GROUP BY Winner
	)
);
.print ' '
.print 'or'
.print ' '
CREATE TEMP VIEW winnerTable AS
SELECT homeID AS Winner,count(*) AS Wins,1 AS atHome
FROM Matches
WHERE homeGoals>awayGoals
GROUP BY Winner
	UNION
SELECT awayID AS Winner,count(*) AS Wins,0 AS atHome
FROM Matches
WHERE awayGoals>homeGoals
GROUP BY Winner;

SELECT Winner,sum(Wins) AS totalWins
FROM winnerTable
GROUP BY Winner
HAVING totalWins=(
	SELECT max(totalWins)
	FROM (
		SELECT Winner,sum(Wins) AS totalWins
		FROM winnerTable
		GROUP BY Winner
	)
);
.print ' '
.print '13. Find those matches where own goal was scored.'
SELECT id
FROM Matches, (
	SELECT matchID,teamID,count(*) AS goals
	FROM Goals
	GROUP BY matchID,teamID
) ON Matches.id=matchID AND homeID=teamID
WHERE homeGoals<>goals;
