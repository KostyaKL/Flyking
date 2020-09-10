class globalVars{
	private static var instance = null;

	private var rec_stat = false;
	
	function set_rec_stat(stat){
		rec_stat = stat;
	}
	
	
	public static function getInstance() {
      if(instance == null) {
         instance = new globalVars();
      }
      return instance;
   }
	
}