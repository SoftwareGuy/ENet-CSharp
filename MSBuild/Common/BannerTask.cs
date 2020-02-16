/*
 * Copyright (c) 2019 Chris Burns <chris@kitty.city>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
using System;
using System.IO;
using System.Threading;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

public class BannerTask : Task
{
    ITaskItem _textFileItem;
    FileStream _fileStream;
    StreamReader _filein;
    StreamWriter _stdout;
    bool _taskSucceeded;
    int _width;

    [Required]
    public ITaskItem TextFile { get; set; }

    public override bool Execute()
    {
        try
        {
            _textFileItem = TextFile;
            if (_textFileItem == null || _textFileItem.ItemSpec.Length <= 0)
            {
                throw new FileNotFoundException("Invalid TaskItem passed to BannerTask::TextFile");
            }

            _taskSucceeded = true;
            using (_fileStream = new FileStream(_textFileItem.ItemSpec, FileMode.Open, FileAccess.Read))
            using (_filein = new StreamReader(_fileStream))
            using (_stdout = new StreamWriter(Console.OpenStandardOutput()))
            {
                _stdout.AutoFlush = true;
                _width = Console.BufferWidth;
                if (_width >= 80)
                {
                    while (_filein.Peek() > 0)
                    {
                        _stdout.WriteLine(_filein.ReadLine());
                        Thread.Sleep(5);
                    }
                }
            }
        }
        catch (Exception e)
        {
            Log.LogError("ENET-CSharp Build Error: " + e.Message);
            // c6: oh i know how to fix that; it needs to just skip the console output thing if its win7
            // _taskSucceeded = false;
        }

        return _taskSucceeded;
    }
}
