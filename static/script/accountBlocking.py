from browser import document, ajax, console, window,html

def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['message'].innerHTML="please enter valid inputs..."
        elif result=='1':
            document['message'].innerHTML="account blocked successfully.."
        else:
            document['message'].innerHTML="account unblocked successfully.."
    else:
        print("Request failed:", req.status)

def accountBlocking(ev):
    account=document['source'].value
    req = ajax.ajax()
    req.bind('complete', handle_response)
    req.open('POST', f'/accountBlocking?account={account}')
    req.send()


document["send"].bind("click", accountBlocking)


