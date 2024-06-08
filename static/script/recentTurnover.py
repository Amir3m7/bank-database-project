from browser import document, ajax, console, window,html

def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['message'].innerHTML="please enter valid inputs..."
        else:
            document['message'].innerHTML=""
            document['customers'].innerHTML=""
            result=eval(result.replace('false','False').replace('true','True'))
            # console.log(result)
            if len(result)>0:
                tableRow = html.TR()
                table_header = html.TH("transaction id")
                tableRow <= table_header
                table_header = html.TH("src")
                tableRow <= table_header
                table_header = html.TH("des")
                tableRow <= table_header
                table_header = html.TH("amount")
                tableRow <= table_header
                table_header = html.TH("date")
                tableRow <= table_header
                table = document["customers"] 
                table <= tableRow
                for account in result:
                    tableRow = html.TR()
                    for fild in account:
                        table_data = html.TD(f"{fild}")
                        tableRow <= table_data
                    table <= tableRow
            else:
                document['customers'].innerHTML='<h2>this acount have not any transaction</h2>'
    else:
        print("Request failed:", req.status)

def recentTurnover(ev):
    account=document['source'].value
    numberInput=document['numberInput'].value
    if len(numberInput)==0 or int(numberInput)<1:
        document['message'].innerHTML="please enter valid number..."
        return
    req = ajax.ajax()
    req.bind('complete', handle_response)
    req.open('POST', f'/recentTurnover?account={account}&numberInput={numberInput}')
    req.send()


document["send"].bind("click", recentTurnover)


