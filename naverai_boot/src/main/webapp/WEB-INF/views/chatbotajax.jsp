<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="js/jquery-3.6.4.min.js"></script>
<script>
$(document).ready(function(){
	//1 type button 클릭하면 request 질문을 response 붙여넣는다
	$("input:button").on("click", function(){
		$("#response").append("질문 : " + $("#request").val() +"<br>");
		$.ajax(
		{
			url:"/chatbotajaxprocess",
			data: {"request": $("#request").val() , "event" : $(this).val()},
			type:'get',
			dataType :'json',
			success : function(server){
				let bubbles = server.bubbles;
				for(let b in bubbles){
					//1.기본(텍스트/ 텍스트+url)
					if(bubbles[b].type=='text'){
						$("#response").append("기본답변 : " + bubbles[b].data.description + "<br>");
						if(bubbles[b].data.url != null){ //url 있다면
							$("#response").append
							('<a href=' + bubbles[b].data.url + '>' + bubbles[b].data.description + '</a><br>');
						}
						$.ajax({
							url : '/chatbottts',
							data : {'text' : bubbles[b].data.description },
							type:'get',
							dataType : 'json',
							success : function(server){
								//alert(server.mp3);
								// id tts audio 태그 재생 
								//1.id tts  태그 dom 읽자
								let audio = document.getElementById("tts");
								
								//2. 1번 src 속성 재생 mp3 지정
								audio.src = "/naverimages/"+server.mp3;
								
								//3. 1번 play()
								audio.play();
								
							},
							error : function(e){
								alert(e);
							}
						});
					
						//////////////////////////////////////
						// 피자주문시작
						////////////////////////////////////
						var order_reply = bubbles[b].data.description
						if(order_reply.indexOf("주문하셨습니다.") >= 0){
							var split_result = order_reply.split(" ");
							var kind = split_result[0];
							var size = split_result[1];
							var phone = split_result[4];
							var kinds = ["콤비네이션피자","소세지크림치즈피자","파인애플피자"];
							//
							var prices = [10000, 15000, 12000];
							
							var sizes = ["소","중","대","특대"];
							
							var add_prices = [0, 2000, 5000, 10000];
							// 소 - 기본가격, 중 - 기본가격+2000, 대 - 기본가격+5000, 특대 - 기본가격+10000
							
							var price = 0;
							var addPrice = 0;
							var totalProce = 0;
							
							for(var i = 0; i < kinds.length; i++ ){
								if(kind == kinds[i]){
									price = prices[i];
									break;
								}
							}
							
							for(var i = 0; i < sizes.length; i++ ){
								if(size == sizes[i]){
									addPrice = add_prices[i];
									break;
								}
							}
							totalPrice = price + addPrice;
							$("#response").append("총 지불 가격 : " + totalPrice);
							
							$.ajax({
								url : "/pizzaorder",
								data : {"kind": kind, "size":size, "price":totalPrice, "phone": phone},
								type:"get",
								dataType:"json",
								success : function(server){
									alert(server.insertrow);
								}
							});
						}
						
						
						
						//////////////////////////////////////
						// 피자주문종료
						////////////////////////////////////
						
					}
					//이미지이거나 멀티링크
					else if(bubbles[b].type=='template'){
						//2.이미지(이미지)
						if(bubbles[b].data.cover.type == 'image'){
							$("#response").append
							('<img src=' + bubbles[b].data.cover.data.imageUrl + ' width=200 height=200 ><br>');
						}
						//3.멀티링크(url) 
						else if(bubbles[b].data.cover.type == 'text'){
							$("#response").append("멀티링크답변 : " + bubbles[b].data.cover.data.description + "<br>");
							//
						}
						//4.이미지+멀티링크 공통(url)
						for(let c in bubbles[b].data.contentTable){
							for(let d in bubbles[b].data.contentTable[c]){
								let link = bubbles[b].data.contentTable[c][d].data.title;
								let href = bubbles[b].data.contentTable[c][d].data.data.action.data.url;
								$("#response").append('<a href=' + href +'> ' + link +'</a><br>');
							}
						}
					
					}
				
				}//for(let b in bubbls) end 	
			},//success end
			error :function(e){alert(e);}
		}
		);//ajax end
		
		
	});//on
});//ready
</script>
</head>
<body>

질문 : <input type=text id="request" >
<input type=button value="답변" id='event1' >
<input type=button value="웰컴메시지" id='event2' >
<button id="record">음성질문녹음시작</button>
<button id="stop">음성질문녹음종료</button>
<div id="sound"></div>

<br>
대화내용 : <div id="response" style="border:2px solid aqua"></div> 
음성답변 : <audio id="tts"  controls="controls" ></audio>

<script>
let record = document.getElementById("record");
let stop = document.getElementById("stop");
let sound = document.getElementById("sound");

//브라우저 녹음기나 카메라 사용 지원여부. 
if(navigator.mediaDevices){
	console.log("지원가능");
	var constraint = {"audio":true};//녹음기 활성화
}

// 녹음 진행 동안 - blob 객체 - 녹음 종료 - mp3파일 생성 저장 
let chunks = [];
navigator.mediaDevices.getUserMedia(constraint)
.then( function(stream){
	var mediaRecorder = new MediaRecorder(stream);//녹음기 준비
	record.onclick = function(){
		mediaRecorder.start();
		record.style.color = "red";
		record.style.backgroundColor = "blue";
	}
	stop.onclick = function(){
		mediaRecorder.stop();
		record.style.color = "";
		record.style.backgroundColor = "";
	}
	
	//녹음시작상태이면 chunks에 녹음 데이터 저장하라
	 mediaRecorder.ondataavailable = function(d){
		chunks.push(d.data);
	}

	//녹음정지상태이면 chunks=>blob -> mp3
	mediaRecorder.onstop = function(){
		//audio 태그 추가하라
		var audio = document.createElement("audio");//<audio></audio>
		audio.setAttribute("controls", "");
		audio.controls = true;//<audio controls></audio>
		
		sound.replaceChildren(audio);
		sound.appendChild(audio); // <div > <audio controls></audio> </div>
		
		//녹음 데이터 가져와서 blob -> mp3 ->audio 태그 재생
		var blob = new Blob(chunks, {"type":"audio/mp3"} );
		var mp3url = URL.createObjectURL(blob);
		audio.src = mp3url;
		
		//다음 녹음 위해 chunks 초기화
		chunks = [];
		
		//var a = document.createElement("a");
		//sound.appendChild(a); // <div > <audio controls></audio><a href=mp3파일명 >파일로 저장</a> </div>
		//a.href=mp3url;
		//a.innerHTML = "파일로 저장";
		//a.download = "a.mp3";
		//클라이언트 브라우저 지정 경로\a.mp3 저장
		
		//스프링부트 서버 요청 a.mp3 upload+ajax
		// new FormData()
		var formData = new FormData();
		formData.append("file1", blob, "a.mp3");
		$.ajax({
			url : "/mp3upload",
			data : formData,
			type : "post",
			processData : false,
			contentType : false,
			success : function(server){
				// a.mp3파일 서버 녹음파일 저장 --> stt
				$.ajax({
					url:"/chatbotstt",
					data : {"mp3file": "a.mp3"},
					type: "get",
					dataType : 'json',
					success : function(server){
						$("#request").val(server.text);
					}
				});
			},
			error : function(e){
				alert(e);
			}
			
		});
		

	}
})//then end
.catch(function(err){console.log("오류발생" + err)});//catch end


</script>


</body>
</html>