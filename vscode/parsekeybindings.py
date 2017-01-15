import json

with open('./kebindings.json','r') as f:
    keys_list = json.load(f)


def search_keybinding(keybindings):
    search_results = []
    for i in keys_list:
        if i["key"] == keybindings:
            search_results.append(i)

    return search_results

def replace_keybinding(old_bind, new_bind, search_results):
    replace_results = []
    for i in search_results:
        if i["key"] == old_bind:
            i_new = dict(i,key=new_bind)
            replace_results.append(i_new)

    return replace_results

def dump_json(filename, json_file):
    with open('./'+filename, 'w') as f:
        json.dump(json_file, f)


if __name__ == "__main__":

    old_key = "escape"
    new_key = "ctrl+g"

    search_results = search_keybinding(old_key)
    replace_results = replace_keybinding(old_key, new_key, search_results)

    dump_json('new_bindings.json', replace_results)


