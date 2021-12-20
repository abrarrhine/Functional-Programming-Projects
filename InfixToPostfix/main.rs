use std::fs::File;
use std::io::{BufReader, Error, BufRead};
use std::env;
use std::path::Path;
use std::io::Write;

/**
 * Main function of this file
 */
fn main() -> Result<(), Error> {

let arg : Vec<String> = env::args().collect(); 
let count = arg.len();
  if count == 3 {
  let path = Path::new(&arg[1]);
  let file = File::open(&path)?;
  let reader = BufReader::new(file);
  let mut result = File::create(&arg[2])?; 
  let mut stack: Vec<String> = Vec::new();
  
  for line in reader.lines()
  {
    let this_line = line.unwrap();
    if toofewopen(this_line.clone()) {
      result.write_all("Too few opening parenthesis\n".as_bytes())?;
    }
    else if toofewclose(this_line.clone()) {
      result.write_all("Too few closing parenthesis\n".as_bytes())?;
    }
    else {
        for word in this_line.split(" "){
          if word == "+" || word == "-" || word == "*" || word == "/" {
              while !stack.is_empty() && precedence(stack.last().unwrap().to_string()) >= precedence(word.to_string()){
                let peek:String = stack.pop().unwrap();
                result.write_all(peek.as_bytes())?;
                result.write(" ".as_bytes())?;

              }
              stack.push(word.to_string());
          } 
          else if word == "(" {          
            stack.push(word.to_string());
          } 
          else if word == ")" {
            while !stack.is_empty(){
                         let peek:String = stack.pop().unwrap();
                         if peek.ne("(") {
                          result.write_all(peek.as_bytes())?;
                          result.write_all(" ".as_bytes())?;
                          }
                          if peek == "("{
                              stack.push(peek);
                              break;
                          }
                    }
                    stack.pop();
          } 
          else{            
            result.write_all(word.as_bytes())?;
            result.write_all(" ".as_bytes())?;
          }
        }
        while !stack.is_empty(){
          result.write_all(stack.pop().unwrap().as_bytes())?;
          result.write_all(" ".as_bytes())?;
        }
        result.write_all(" \n".as_bytes())?;
          }
      }
  }
  else {
      println!("Too few arguments");
  }

  Ok(())
}

/**
 * This function returns precedence value depending 
 * on the operator
 */
fn precedence(c: String)-> i32{
  if c == "+" || c == "-"{
    return 1; 
  }
  else if c == "*" || c == "/"{
    return 2; 
  } 
  else {
    return 0; 
  }
}

/**
 * This function check is there is too few 
 * opening parenthesis and returns boolean 
 */
fn toofewopen(exp: String) -> bool {
  let mut opencount: i32 = 0;
  let mut closecount: i32 = 0;

  for word in exp.split(" "){
    if word == "("{
      opencount += 1; 
    }
    if word == ")"{
      closecount += 1; 
    }
  }
  if closecount > opencount {
    return true; 
  }
  return false; 
}

/**
 * This function check is there is too few 
 * closing parenthesis and returns boolean 
 */
fn toofewclose(exp: String) -> bool {
  let mut opencount: i32 = 0;
  let mut closecount: i32 = 0;

  for word in exp.split(" "){
    if word == "("{
      opencount += 1; 
    }
    if word == ")"{
      closecount += 1; 
    }
  }
  if opencount > closecount{
    return true; 
  }
  return false;
}