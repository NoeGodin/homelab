# Set up

I had a lot of struggles to set this up.
If you use a domain make sure qBittorent isn't running (otherwise it will override the following configurations)

Modify the conf file and add the following :
```
WebUI\CSRFProtection=false
WebUI\HostHeaderValidation=false
WebUI\LocalHostAuthentication=false
```

Make sure that the user ${PUID} can read/write on the volumes.

In qBittorent's web interface go to advanced settings :
Set the correct network interface / type of addresses available (in my case tun0/Ipv4)

And change the default download location to the correct one.