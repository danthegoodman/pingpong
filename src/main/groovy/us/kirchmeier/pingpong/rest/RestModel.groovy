package us.kirchmeier.pingpong.rest

interface RestModel {
    Map toJson()
    Integer get_id()
    void set_id(Integer id)
}
