define :monit_config, :enable => true, :source => nil, :variables => {} do
  template_source = params[:source] ? params[:source] : "#{params[:name]}.monitrc.erb"
  
  template "/etc/monit/conf.d/#{params[:name]}.monitrc" do
    source template_source
    mode 0644
    
    owner "root"
    group "root"
        
    variables params[:variables]
    backup false
        
    if params[:enable]
      action :create
    else
      action :delete
    end
    
    notifies :restart, resources(:service => "monit")
        
  end
  
end
