from browser import document, ajax, console, window,html

def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['message'].innerHTML="please enter valid inputs..."
        else:
            result=eval(result.replace('false','False').replace('true','True'))
            document['customers'].innerHTML=''
            document['message'].innerHTML=""
            # console.log(result)
            if len(result)>0:
                tableRow = html.TR()
                table_header = html.TH("acount")
                tableRow <= table_header
                table_header = html.TH("date")
                tableRow <= table_header
                table_header = html.TH("account balance")
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
                document['customers'].innerHTML='<h2>this acount have not any transaction in this range</h2>'
    else:
        print("Request failed:", req.status)

def accountTurnoverBetween(ev):
    account=document['source'].value
    from_=document['from'].value
    to=document['to'].value
    req = ajax.ajax()
    req.bind('complete', handle_response)
    req.open('POST', f'/accountTurnoverBetween?account={account}&from={from_}&to={to}')
    req.send()


document["send"].bind("click", accountTurnoverBetween)


