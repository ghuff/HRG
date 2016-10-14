import de.bezier.data.sql.*;


// created 2005-05-10 by fjenett
// updated fjenett 20081129





class MedusaSQLHandler{

  
    private String user     = "root";
    private String pass     = "T3xasaggies10!";
    private String database = "medusa";
    private String host = "localhost";
    private MySQL msql;
    private PApplet parent;
    
    private boolean isConnected = false;
    
    public MedusaSQLHandler(){
     this.user = "root";
     this.pass = "T3xasaggies10!";
     this.database = "medusa";
     this.host = "localhost";
     this.isConnected = false;
     connect(); 
    }
    
    public MedusaSQLHandler(PApplet _parent){
     this.user = "root";
     this.pass = "T3xasaggies10!";
     this.database = "medusa";
     this.host = "localhost";
     this.isConnected = false;
     this.parent = _parent;
     connect(); 
    }
    
    public MedusaSQLHandler(String _user, String _pass, String _database, String _host){
        this.user = _user;
        this.pass = _pass;
        this.database = _database;
        this.host = _host;
        this.isConnected = false;
        connect();
    }
    
    public boolean connect(){
       msql = new MySQL( parent, "localhost", database, user, pass );
    
        if ( msql.connect() )
        {
            //msql.query( "SELECT COUNT(*) FROM elements" );
            //msql.next();
            isConnected = true;
            println( "Database "+database+ " connected!" );
            return true;
        }
        else
        {
            println( "Could not connect to "+database);
            return false;
        }
    }
    
    //getters
    public String getUser(){
       return this.user; 
    }
    
    public String getPass(){
       return this.pass; 
    }
    
    public String getDatabase(){
       return this.database; 
    }
    
    public String getHost(){
       return this.host; 
    }
    
    public boolean isConnected(){
       return isConnected; 
    }
    
    //setters
    public void setUser(String _user){
       this.user = _user;     
    }
    
    public void setPass(String _pass){
       this.pass = _pass; 
    }
    
    public void setHost(String _hostname){
       this.host = _hostname; 
    }
    
    public void setDatabase(String _database){
       this.database = _database; 
    }
    
}
