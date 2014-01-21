describe WebStub::URI do
  it "parses a multipart form with a single field into a hash" do
   content_type = "multipart/form-data; boundary=4A883BDD-0E61-444E-B18F-F38E26CF84FF"
    body = ['--4A883BDD-0E61-444E-B18F-F38E26CF84FF',
            'Content-Disposition: form-data; name="authentication_token"',
            "",
            'abcde1',
            '--4A883BDD-0E61-444E-B18F-F38E26CF84FF'].join("\r\n")
    WebStub::Form.decode_multipart_form(content_type, body).should.equal(
      {'authentication_token' => "abcde1"}
    )
  end

  it "parses a multipart form with many fields into a hash" do
   content_type = "multipart/form-data; boundary=4A883BDD-0E61-444E-B18F-F38E26CF84FF"
    body = ['--4A883BDD-0E61-444E-B18F-F38E26CF84FF',
            'Content-Disposition: form-data; name="authentication_token"',
            "",
            'abcde1',
            '--4A883BDD-0E61-444E-B18F-F38E26CF84FF',
            'Content-Disposition: form-data; name="other_token"',
            "",
            'hiya',
            '--4A883BDD-0E61-444E-B18F-F38E26CF84FF',
    ].join("\r\n")
    WebStub::Form.decode_multipart_form(content_type, body).should.equal(
      {'authentication_token' => "abcde1", 'other_token' => 'hiya'}
    )
  end

  it "parses a key value pair from a chunk of body" do
    chunk = ['Content-Disposition: form-data; name="authentication_token"',
             "",
             "abcde1\r\n"].join("\r\n")
    body = {}
    WebStub::Form.parse_chunk(chunk, body)

    body.should.equal(
      {'authentication_token' => "abcde1"}
    )
  end

  it "parses the boundary from the content type" do
    boundary = "4A883BDD-0E61-444E-B18F-F38E26CF84FF"
    content_type = "multipart/form-data; boundary=#{boundary}"
    WebStub::Form.parse_boundary(content_type).should.equal boundary
  end

  it "parses a multipart with array notation into a nested hash" do
   content_type = "multipart/form-data; boundary=4A883BDD-0E61-444E-B18F-F38E26CF84FF"
    body = ['--4A883BDD-0E61-444E-B18F-F38E26CF84FF',
            'Content-Disposition: form-data; name="user[authentication_token][signature]"',
            "",
            'abcde1',
            '--4A883BDD-0E61-444E-B18F-F38E26CF84FF'].join("\r\n")
    WebStub::Form.decode_multipart_form(content_type, body).should.equal(
      {'user' => {'authentication_token' => {'signature' => "abcde1"}}}
    )
  end

  it "splits array notation keys" do
    WebStub::Form.split_keys("user[authentication_token][signature]").should.equal( %w{user authentication_token signature} )
  end
end
