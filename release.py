from subprocess import call, Popen, PIPE
import toml
import zipfile
import os

default_target = 'i686-pc-windows-gnu'

def build_dys(target):
    p = Popen(
        ["cargo", "build", "--release", f"--target={target}"],
        cwd = "./src/rs"
    )
    return p.wait() == 0

def dys_version(target):
    cargot = toml.load("./src/rs/Cargo.toml")
    cargover = cargot["package"]["version"]
    p = Popen(
        ["cargo", "run", "--release", f"--target={target}", "--", "-V"],
        cwd = "./src/rs",
        stdout=PIPE, stderr=PIPE
    )
    # "errs" also includes non-error Cargo output
    output, errs = p.communicate()
    soutput = output.decode('utf-8')
    expected_ver = f"Daiyousei version {cargover}"
    # startswith is mainly to avoid newline weirdness that might arise
    if not soutput.startswith(expected_ver):
        return None
    return cargover


def build_book():
    p = Popen(
        ["mdbook", "build"],
        cwd = "./src/docbook"
    )
    return p.wait() == 0

def compile_zip(target, ver):
    if not os.path.isdir('release'):
        os.mkdir('release')
    dash_ver = ver.replace('.','-')
    zip = zipfile.ZipFile(f"release/daiyousei-{dash_ver}.zip", 'w')
    zipdir('./src/docbook/book', zip)
    zipdir('./src/docbook/src', zip)
    zipdir('./src/rs', zip, exclude=['./src/rs/target'])
    zipdir('./patch', zip)

    if target.find('windows') >= 0:
        name_bin = 'daiyousei.exe'
        name_asar = 'asar.dll'
    else:
        name_bin = 'daiyousei'
        nama_asar = 'asar.so'

    zip.write('./readme.html', arcname='./readme.html')

    zip.write(f'./src/rs/target/{target}/release/{name_bin}', arcname=f'./{name_bin}')
    zip.write(f'./{name_asar}', arcname=f'./{name_asar}')

    optional_dirs = [
        'sprites','shooters', 'generators', 'clusters', 'overworld',
        'subroutines',
    ]
    for dir in optional_dirs:
        if os.path.isdir(dir):
            zipdir(dir, zip)
    return True

def zipdir(path, zip, exclude=[]):
    path = os.path.normpath(path)
    for root, dirs, files in os.walk(path):
        for file in files:
            srcfile = os.path.join(root, file)
            dstfile = os.path.join('.', root, file)
            skip = False
            for dir in exclude:
                if os.path.samefile(os.path.commonpath([srcfile, dir]), dir):
                    skip = True
                    break
            if skip:
                continue
            zip.write(os.path.join(root, file), arcname=dstfile)

if __name__ == '__main__':
    from sys import exit
    target = default_target
    if not build_dys(target):
        print("failed building daiyousei; no release built")
        exit(1)
    ver = dys_version(target)
    if ver is None:
        print("daiyousei reports a wrong version; no release built")
        exit(1)
    if not build_book():
        print("failed building docbook; no release built")
        exit(1)
    if not compile_zip(target, ver):
        print(f"failed compiling zip")
        exit(1)