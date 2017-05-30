# Software API Description

*This list of APIs is described in `ASPCommunication.java` in detail*

**`void sendPacket(int packet)`**            

Sends the packet to datacall port



**`int pollASPResponse()`**                  

Polls the datacall and checks `valid` and `legacy` bits



**`int storeReset(int memSel)`**         

Sends a `reset` command to ASP. Polls for Access Granted and return it.



**`int store(int[] data, int start, int memSel)` **
Sends a `store` command storing an array from `start` to `start + data.length`. Polls for Access Granted and return it.



**`int xor(int memSel, int start, int end)`**

Sends an `xor` command to ASP from `start` to `end`. Polls for Access Granted and return it. 



**`long mac(int start, int end)`**

Sends a `mac` command to ASP from `start` to `end`. This will keep polling for three packets of data and concatenated into a `long` type number and return it.



**`int ave(int windowSize, int memSel)`**

Sends an `ave` command to ASP with `windowSize` and polls for Access Granted and return it. 

 









