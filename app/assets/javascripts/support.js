var groupBy = function(xs, key) {
    return xs.reduce(function(rv, x) {
      (rv[x[key]] = rv[x[key]] || []).push(x);
      return rv;
    }, {});
  };
  
function find_with_attr(array, attr, value) {
    for(var i = 0; i < array.length; i += 1) {
        if(array[i][attr] === value) {
            return i;
        }
    }
    return -1;
}
  
function find_with_value(array, value) {
    for(var i = 0; i < array.length; i += 1) {
        if(array[i] === value) {
            return i;
        }
    }
    return -1;
}