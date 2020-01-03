function result_table_planning(list, delete_button) {
    var trs = "";
    list.forEach(function(x){
        if(list.indexOf(x) > 0){
           trs += "<tr style=\"background-color:#f8f8f8\"><td colspan=\"5\"></td></tr>";      
        }
        var trRow = "<tr><td rowspan=" + (x.disciplines.length + 1) + ">" + x.semester.year +"."+x.semester.period  + "</td></tr>";
        trs += trRow;
        x.disciplines.forEach(function(d){
          var td =
            "<td>" + d.nature + "</td>" +
            "<td>" + d.code + "</td>" +
            "<td>" + d.name + "</td>";
            if(delete_button){
                var delete_Record = "<a class=\"delete-record-planning\"data-id=" + d.code + ">Excluir</a></td>"
                td = td + "<td>" + delete_Record + "</td>";
            }
            var tr = "<tr id= recPlanning-" + d.code + ">" + td + "</tr>";
            trs += tr;
        });
    });
    return trs;
}