library pingpong.common.functions;

int serverIndex(int points, int players){
  if(points < 40){
    return (points % (players * 5)) ~/ 5;
  } else {
    return points % players;
  }
}

num rollingAverage(List<num> values, int lengthLimit){
  if(values.isEmpty) return null;

  var sum = 0;
  var count = 0;
  var len = (values.length < lengthLimit ? values.length : lengthLimit);

  for(var i = 0; i < len; i++){
    var multiplier = (lengthLimit-i)/lengthLimit;
    sum += (values[i] * multiplier);
    count += multiplier;
  }

  return sum/count;
}
