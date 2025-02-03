package mymapping;

import java.io.FileWriter;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.example.ai.MyNaverInform;
import com.example.ai.NaverService;

@Controller
public class MapController {
	@Autowired
	@Qualifier("mapservice")
	NaverService service ;
	
	@Autowired
	@Qualifier("ttsservice")
	NaverService service2;
	
	@GetMapping("/myinput")
	public String input() {
		return "mymapping/input";
	}
	
	/*@RequestMapping("/myoutput")
	public ModelAndView output(String request) throws IOException {
		String response = service.test(request);
		//답변텍스트를 txt파일 생성
		FileWriter fw = new FileWriter(MyNaverInform.path + "response.txt");
		fw.write(response);
		fw.close();
		String mp3 = service2.test("response.txt");
		ModelAndView mv = new ModelAndView();
		mv.addObject("response", response);//답변(텍스트)
		mv.addObject("mp3", mp3);//답변(음성)
		mv.setViewName("mymapping/output");
		return mv;
	}*/
	
	@RequestMapping("/myoutput")
	@ResponseBody  //ajax (sts3 - pom.xml 라이브러리 추가 / sts4 - 자동추가)
	public String output(String request) throws IOException {
		String response = service.test(request);
		//답변텍스트를 txt파일 생성
		FileWriter fw = new FileWriter(MyNaverInform.path + "response.txt");
		fw.write(response);
		fw.close();
		String mp3 = service2.test("response.txt");
		return 	 "{\"response\" : \""  +  response + "\" , \"mp3\":\"" + mp3 + "\" }";
	}
	
}





