from browser import document, ajax, console, window

def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=="Please log in.":
            window.location.href = '/login'
        else:
            document['name'].innerHTML=result    
    else:
        print("Request failed:", req.status)

req = ajax.ajax()
req.bind('complete', handle_response)
req.open('POST', f'/mainPage')
req.send()












# def handle_response(req):
#     if req.status == 200:  # Successful response
#         result=req.text
#         console.log(result)
#         if result=='0':
#             document['message'].innerHTML="your password or username is incorrect! try again..."
#         else:
#             window.location.href = '/mainPage'
#     else:
#         print("Request failed:", req.status)

# def login(ev):
#     username=document['username'].value
#     password=document['password'].value
#     req = ajax.ajax()
#     req.bind('complete', handle_response)
#     req.open('POST', f'/login?username={username}&password={password}')
#     req.send()


# document["send"].bind("click", login)


