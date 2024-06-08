from browser import document, ajax, console, window, html



def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        result=eval(result.replace('false','False').replace('true','True'))
        console.log(result)
        if len(result)>0:
            document['message'].innerHTML=""
            document['customers'].innerHTML=""
            tableRow = html.TR()
            table_header = html.TH("user id")
            tableRow <= table_header
            table_header = html.TH("loan id")
            tableRow <= table_header
            table_header = html.TH("account")
            tableRow <= table_header
            table_header = html.TH("ammount")
            tableRow <= table_header
            table = document["customers"] 
            table <= tableRow
            for account in result:
                tableRow = html.TR()
                for index, fild in enumerate(account):
                    if index==1:
                        a_element = document.createElement('a')
                        a_element.text = f"{fild}"
                        a_element.href = f'/loanId?loanId={fild}'
                        table_data = html.TD()
                        table_data <= a_element
                        tableRow <= table_data
                    else:
                        table_data = html.TD(f"{fild}")
                        tableRow <= table_data
                table = document["customers"]  # Get the table element by its ID
                table <= tableRow
        else:
            document['customers'].innerHTML="<h2>You have not taken any loan!</h2>"
    else:
        print("Request failed:", req.status)


def loading():
    req = ajax.ajax()
    req.bind('complete', handle_response)
    req.open('POST', '/loans')
    req.send()


loading()




def handle_point(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['message'].innerHTML="please enter valid account..."
        else:
            document['message'].innerHTML="point of account is: "+result
    else:
        print("Request failed:", req.status)

def point(ev):
    account=document['source'].value
    req = ajax.ajax()
    req.bind('complete', handle_point)
    req.open('POST', f'/loans?action=point&account={account}')
    req.send()


document["point"].bind("click", point)







def handle_get(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['message'].innerHTML="please enter valid account..."
        else:
            document['message'].innerHTML=""
            loading()
    else:
        print("Request failed:", req.status)

def get(ev):
    account=document['source'].value
    req = ajax.ajax()
    req.bind('complete', handle_get)
    req.open('POST', f'/loans?action=get&account={account}')
    req.send()


document["get"].bind("click", get)