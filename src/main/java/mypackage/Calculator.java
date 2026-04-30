package mypackage;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class Calculator extends HttpServlet
{
	public long addFucn(long first, long second){
		
		return first+second;
	}
	
	public long subFucn(long first, long second){
		
		return second-first;
	}
	
	public long mulFucn(long first, long second){
		
		return first*second;
	}
	
	
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        try
        {
        response.setContentType("text/html");
        PrintWriter out= response.getWriter();
        int a1= Integer.parseInt(request.getParameter("n1"));
        int a2= Integer.parseInt(request.getParameter("n2"));

        String operation = request.getParameter("operation");
        if("add".equals(operation))
        {
            out.println("<h1>Addition</h1>"+addFucn(a1, a2));
        }
        else if("sub".equals(operation))
        {
            out.println("<h1>Subtraction</h1>"+subFucn(a1, a2));
        }
        else if("prod".equals(operation))
        {
            out.println("<h1>Multiplication</h1>"+mulFucn(a1, a2));
        }
        else
        {
            out.println("<p>Please select an operation.</p>");
        }
        RequestDispatcher rd=request.getRequestDispatcher("/index.jsp");  
        rd.include(request, response);  
        }
        catch(Exception e)
        {

        }
    }
}
