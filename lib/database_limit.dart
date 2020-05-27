class DatabaseLimiter{

  //time interval that the user has to wait before they can send another message
  static final int _rateLimitInSeconds = 30;
  int _submitTime = 0;

  bool canSubmitToDb(){
    var curTime = new DateTime.now().millisecondsSinceEpoch;

    if(curTime - _submitTime >= _rateLimitInSeconds * 1000 || _submitTime == 0){
      return true;
    }
    return false;
  }

  void submit(){
    _submitTime = new DateTime.now().millisecondsSinceEpoch;
  }

}