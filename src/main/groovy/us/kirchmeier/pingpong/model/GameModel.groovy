package us.kirchmeier.pingpong.model

import org.bson.types.ObjectId


class GameModel {
    ObjectId _id
    ObjectId parentId
    int gameInMatch
    Date date
    Date finish
    List<Integer> players
    List<String> points

    int getScore(int team) {
        return points.count {
            if (it[1] == '1') {
                return (it[2] as int) % 2 == team
            } else {
                return (it[0] as int) % 2 != team
            }
        }
    }

    Map toMap() {
        def props = properties
        props.remove('class')
        return props;
    }
}
