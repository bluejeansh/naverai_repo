package com.example.ai;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StartController {
//http://localhost:8064/
	@GetMapping("/")
	public String start(){
		Sytem.out.println("이완재회원");
		return "start"; 
	}
}
