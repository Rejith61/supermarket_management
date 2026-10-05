FSMMSDSPF  CF   E             WORKSTN                     
                                                          
D PgmSDS         SDS                                      
D PGMNAM                  1     10A                       
                                                          
D w_Count         S             10I 0                     
D w_DbPass        S             10A                       
                                                          
  Exec Sql Set Option Commit = *None;                     
                                                          
  DoW *IN03 = *Off;                                       
                                                          
      exfmt LOGINREC;                                     
                                                          
      *IN50 = *Off;    //error message indicator          
      *IN51 = *Off;   //success message indicator         
     ERRMSG   = ' ';                                                   
                                                                       
     Select;                                                           
                                                                       
         When *IN03 = *On;                                             
             Leave;                                                    
                                                                       
         // New User Details Update                                    
         When *IN06 = *On;                                             
                                                                       
             If N_EMPID = *Blanks or N_PASS = *Blanks;                 
                 *IN50 = *On;                                          
             ERRMSG = 'Error: Enter both ID and Password to sign up.'; 
                 Iter;                                                 
             EndIf;                                                    
                                                                       
             // Check if Employee already exists                       
            Exec Sql Select Count(*) Into :w_Count                    
                     From USERPF Where U_EMPID = :N_EMPID;            
                                                                      
            If w_Count > 0;                                           
                // Exists: Update Password                            
                Exec Sql Update USERPF                                
                         Set U_PASSWD = :N_PASS                       
                         Where U_EMPID = :N_EMPID;                    
                *IN51 = *On;                                          
                ERRMSG = 'Employee ID already exists. Password Update 
            Else;                                                     
                // New: Insert Record                                 
                Exec Sql Insert Into USERPF (U_EMPID, U_PASSWD)       
                         Values (:N_EMPID, :N_PASS);                  
                *IN51 = *On;                                          
                ERRMSG = 'New Employee Registered Successfully!';     
            EndIf;                                                    
                                                                      
            N_EMPID = *Blanks;                                        
            N_PASS  = *Blanks;                                        
                                                                      
        // Existing User Login                                        
        Other;                                                        
            If E_EMPID = *Blanks or E_PASS = *Blanks;                 
                *IN50 = *On;                                          
                ERRMSG = 'Error: Enter ID and Password to login.';    
                Iter;                                                 
            EndIf;                                                    
                                                                      
            // Fetch the stored password for this ID                  
            Exec Sql Select U_PASSWD Into :w_DbPass                   
                     From USERPF Where U_EMPID = :E_EMPID;            
                                                                      
            // Check if record was found AND passwords match          
              If SqlCode = 0 And %trim(E_PASS) = %trim(w_DbPass);       
                                                                        
C                   CALL      'SMMPGM'                                  
C                   PARM                    E_EMPID                     
                                                                        
                  E_EMPID = *Blanks;                                    
                  E_PASS  = *Blanks;                                    
                                                                        
              Else;                                                     
                  // FAILURE! Wrong ID or Password                      
                  *IN50 = *On;                                          
             ERRMSG = 'Error: Invalid Employee ID or Wrong Password.';  
                                                                        
              EndIf;                                                    
                                                                        
      EndSl;                                                            
                                                                        
  EndDo;                                                  
                                                          
  *InLr = *On;                                            

