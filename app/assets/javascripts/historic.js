 function get_result_table_history(list) {
    var trs = "";
    list.forEach(function(x){
      if(list.indexOf(x) > 0){
        trs += "<tr style=\"background-color:#f8f8f8\"><td colspan=\"5\"></td></tr>";    
      }
      var trRow = "<tr><td rowspan=" + (x.disciplines_historic.length + 1) + ">" + x.semester + "</td></tr>";
        trs += trRow;
        x.disciplines_historic.forEach(function(d){
            var td =
              "<td>" + d.curricular_component + "</td>" +
              "<td>" + (d.ch == 0 ? '--' : d.ch) + "</td>" +
              "<td>" + (d.cr == 0 ? '--' : d.cr) + "</td>" +
              "<td>" + d.nt + "</td>" +
              "<td>" + (['TR', 'RF'].includes(d.res) ? '--' : d.note) + "</td>" +
              "<td>" + d.res + "</td>";
            var tr = "<tr>" + td + "</tr>";
            trs += tr;
        });
    });
    return trs;
}