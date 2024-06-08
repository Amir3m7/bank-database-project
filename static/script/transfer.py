from browser import document, ajax, console, window

def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['Knowing'].innerHTML="unknown"
        else:
            document['Knowing'].innerHTML=result
    else:
        print("Request failed:", req.status)

def handleInputChange(event):
    destination=document['destination'].value
    console.log(destination)
    if len(destination)==0:
        document['source'].innerHTML=''
        return
    req = ajax.ajax()
    req.bind('complete', handle_response)
    req.open('POST', f'/transfer?destination={destination}')
    req.send()
    print("Input value changed:", destination)

my_input = document["destination"]
my_input.bind("input", handleInputChange)



def handle_send(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['message'].innerHTML="transfer failed..."
        else:
            window.location.href = '/transactionSecc'
    else:
        print("Request failed:", req.status)

def send(ev):
    destination=document['destination'].value
    amount=document['amount'].value
    source=document['source'].value
    req = ajax.ajax()
    req.bind('complete', handle_send)
    req.open('POST', f'/transfer?amount={amount}&destination={destination}&source={source}')
    req.send()


document["send"].bind("click", send)




def handle_source_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['source_message'].innerHTML="invalid"
        else:
            document['source_message'].innerHTML='valid'
    else:
        print("Request failed:", req.status)

def handleSourceChange(event):
    source=document['source'].value
    if len(source)==0:
        document['source'].innerHTML=''
        return
    req = ajax.ajax()
    req.bind('complete', handle_source_response)
    req.open('POST', f'/transfer?source={source}')
    req.send()
    print("Input value changed:", source)

input_source = document["source"]
input_source.bind("input", handleSourceChange)
