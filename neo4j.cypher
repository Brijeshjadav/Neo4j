// Step 1: Load the graph data into Neo4j
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Brijeshjadav/Neo4j/main/chat_create_team_chat.csv' AS row
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Brijeshjadav/Neo4j/main/chat_item_team_chat.csv' AS row
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Brijeshjadav/Neo4j/main/chat_join_team_chat.csv' AS row
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Brijeshjadav/Neo4j/main/chat_leave_team_chat.csv' AS row
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Brijeshjadav/Neo4j/main/chat_mention_team_chat.csv' AS row
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Brijeshjadav/Neo4j/main/chat_respond_team_chat.csv' AS row

LOAD CSV FROM "https://raw.githubusercontent.com/Brijeshjadav/Neo4j/main/chat_item_team_chat.csv" AS row
MERGE (u:User {id: toInt(row[0])})
MERGE (t:Team {id: toInt(row[1])})
MERGE (c:TeamChatSession {id: toInt(row[2])})
MERGE (u)-[:CreatesSession{timeStamp: row[3]}]->(c)
MERGE (c)-[:OwnedBy{timeStamp: row[3]}]->(t)

MERGE (n1:Node {id: row.source})
MERGE (n2:Node {id: row.target})
MERGE (n1)-[:CONNECTED_TO]->(n2)

// Step 2: Run the Louvain algorithm for community detection
CALL gds.louvain.write({
  nodeProjection: 'Node',
  relationshipProjection: {
    CONNECTED_TO: {
      type: 'CONNECTED_TO',
      orientation: 'UNDIRECTED'
    }
  },
  writeProperty: 'community'
})

// Step 3: Retrieve the communities and their nodes
MATCH (n:Node)
RETURN n.id, n.community
