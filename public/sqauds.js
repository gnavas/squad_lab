$(document).ready(function(){
$("#back").on("click",function(e){
window.history.back();
});
$(".checkbox").click(function(e){
$(this).parent().parent().toggleClass("checked");
});

$("#delete_all").click(function(e){
  console.log("hello");
  console.log($("#delete_all").parent().attr("action"));
if((confirm("Please click ok to delete all students")===false)){
  $("#delete_all").parent().removeAttr("method");
    // $("#delete_all").parent().attr("action",'#');
}

});


});